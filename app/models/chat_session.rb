class ChatSession < ActiveRecord::Base
  belongs_to :requester, class_name: 'User'
  belongs_to :receiver, class_name: 'User'

  validates_presence_of :requester, :receiver

  before_create :initial_values

  def initial_values
    loop do
      new_uuid = SecureRandom.uuid
      if ChatSession.find_by_uuid(new_uuid).blank?
        self.uuid = new_uuid
        break
      end
    end
    self.status = 'pending'
  end
end
