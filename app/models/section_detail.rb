class SectionDetail < ActiveRecord::Base
  include Discussable

  belongs_to :project

  attr_accessor :discussed_context

  validates :context, :title, presence: true

  def can_update?
    User.current_user.is_admin_for?(project)
  end

  def discussed_context= value
    if can_update?
      self.send(:write_attribute, 'context', value)
    else
      unless value == self.context.to_s
        Discussion.find_or_initialize_by(discussable:self, user_id: User.current_user.id, field_name: 'context').update_attributes(context: value)
      end
    end
  end

  def discussed_context
    can_update? ?
        self.send(:context) :
        discussions.of_field('context').of_user(User.current_user).last.try(:context) || self.send(:read_attribute, 'context')
  end

end