FactoryGirl.define do
  factory :task do
    sequence(:title) { |n| "task #{n}" }
    budget 0
    target_number_of_participants 0
    sequence(:condition_of_execution) { |n| "condition_of_execution #{n}" }
    sequence(:proof_of_execution) { |n| "proof_of_execution #{n}" }
    sequence(:deadline) { |n| n.days.from_now }
    state 'accepted'

    trait :suggested do
      state { 'suggested_task' }
    end

    trait :pending do
      state { 'pending' }
    end

    trait :with_associations do
      association :user, :confirmed_user, factory: :user
      association :project, factory: :base_project
      budget { 100 }
      deadline { 30.days.from_now }
    end
  end
end
