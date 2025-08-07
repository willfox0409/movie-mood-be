FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "test#{n}@example.com" }
    sequence(:username) { |n| "testuser#{n}" }
    password { "tarantino123" }
    password_confirmation { "tarantino123" }
  end
end