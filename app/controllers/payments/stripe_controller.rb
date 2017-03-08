class Payments::StripeController < ApplicationController
  before_filter :check_form_validity, only: :create
  include ApplicationHelper
  before_action :authenticate_user!

  def new
    @task = Task.find(params[:id])
    @available_cards = Payments::StripeSources.new.call(user: current_user)
  end


  def create
    reserve_wallet_balance = get_reserve_wallet_balance
    #deduct 5% amount as described in fund_popup
   fee_amount = (params[:amount].to_f * 5)/100
    remaining_amount = params[:amount].to_f - fee_amount
    satoshi_amount = convert_usd_to_btc_and_then_satoshi(remaining_amount)
    if reserve_wallet_balance < satoshi_amount && ENV['skip_wallet_transaction'] != "true"
      flash[:alert] = 'Not Enough BTC in Reserve wallet Please Try Again .'
      redirect_to taskstab_project_url(id: params[:project_id])
    else
      payment_description = "Payment of #{params[:amount]} for task: #{params[:id]} for project: #{params[:project_id]}"

      if payment_service.charge!(amount: params[:amount], description: payment_description)
        task = Task.find(params[:id])
        stripe_response = JSON(payment_service.instance_variable_get(:@stripe_response).to_s)
        if ENV['skip_wallet_transaction'] == "true"
          StripePayment.create(amount: params[:amount], user_id: current_user.id, task_id: task.id, amount_in_satoshi: satoshi_amount, stripe_token: params[:stripeToken], stripe_response_id: stripe_response['id'], balance_transaction: stripe_response['balance_transaction'], paid: stripe_response['paid'], refund_url: stripe_response['refunds']['url'], status: stripe_response['status'], seller_message: stripe_response['outcome']['seller_message'])
        else
          transfer_coin_from_weserver_wallet_to_task_wallet(task, satoshi_amount, params[:amount], params[:stripeToken], stripe_response['id'], stripe_response['balance_transaction'], stripe_response['paid'], (stripe_response.fetch('refunds', {})['url']), stripe_response['status'], (stripe_response.fetch('outcome', {})['seller_message']))

        end
        # task_id :   amount:;
        #   rails generate model StripePayments amount:decimal task:references
        # 1: TO DO: convert this USD amount from Dollars to Satoshi
        # 2: TO DO: Transfer this amount of Satoshi from the general WeServe BitGO account to the the one that belongs to the task wallet_id
        # params[:wallet_transaction_user_wallet] is available and is the one that can be used to move the money from the general WeServeBitGo
        flash[:notice] = 'Thanks for your payment'
        redirect_to taskstab_project_url(id: params[:project_id])
      else
        flash[:alert] = payment_service.error
        redirect_to taskstab_project_url(id: params[:project_id])
      end
    end

  end

  private

  def payment_service
    @payment_service ||= Payments::Stripe.new(payment_service_options)
  end

  def payment_service_options
    if params[:card_id]
      {
        card_id: params[:card_id],
        user: current_user
      }
    elsif params[:stripeToken]
      {
        stripe_token: params[:stripeToken],
        persist_card: params[:save_card].present?,
        user: current_user
      }
    end
  end

  def transfer_coin_from_weserver_wallet_to_task_wallet (task, satoshi_amount, amount, stripe_token, stripe_response_id, balance_transaction, paid, refund_url, status, seller_message)
    task_wallet = task.wallet_address.sender_address
    begin
      @transfer = StripePayment.create(amount: amount, task_id: task.id, user_id: current_user.id, stripe_token: stripe_token, stripe_response_id: stripe_response_id, balance_transaction: balance_transaction, paid: paid, refund_url: refund_url, status: status, seller_message: seller_message, amount_in_satoshi: satoshi_amount)
      if satoshi_amount.eql?('error') or satoshi_amount.blank?
        return
      else
        access_token = ENV['bitgo_admin_weserve_admin_access_token']
        address_from = ENV['reserve_wallet_id'].strip
        sender_wallet_pass_phrase = ENV['reserve_wallet_pass_pharse'].strip
        address_to = task_wallet.strip
        api = Bitgo::V1::Api.new
        @res = api.send_coins_to_address(wallet_id: address_from, address: address_to, amount: satoshi_amount, wallet_passphrase: sender_wallet_pass_phrase, access_token: access_token)
        if @res["message"].blank?
          @transfer.tx_hash = @res["tx"]
          @transfer.transferd = true
          @transfer.amount_in_satoshi = satoshi_amount
          @transfer.save!
        end
      end
    end
  end


  def check_form_validity
    redirect_to(card_payment_project_task_url) unless (params.key?(:stripeToken) || params.key?(:card_id)) && params.key?(:amount)
  end
end
