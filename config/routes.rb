Rails.application.routes.draw do
  get 'payment_notifications/create'

  get 'proj_admins/new'

  get 'proj_admins/create'

  get 'proj_admins/destroy'
  resources :proj_admins do
    member do
      get :accept, :reject
    end
  end
  resources :assignments do
    member do
      get :accept, :reject, :completed, :confirmed, :confirmation_rejected
    end
  end
  resources :payment_notifications
  resources :donations

  resources :do_for_frees do
    member do
      get :accept, :reject
    end
  end

  resources :do_requests do
    member do
      get :accept, :reject
    end
  end

  resources :activities, only: [:index]
  resources :wikis
  resources :tasks
  resources :projects do
    resources :tasks do
  	 resources :task_comments

     resources :assignments
    end

    resources :project_comments

    member do
      get :accept, :reject
    end
  end

  devise_for :users, :controllers => { registrations: 'registrations' }
  resources :users

  resources :conversations do
    resources :messages
  end

  get 'dashboard' => 'dashboard'

  root to: 'visitors#index'
end
