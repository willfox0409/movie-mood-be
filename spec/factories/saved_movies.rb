FactoryBot.define do
  factory :saved_movie do
    association :user
    association :movie
    title { movie.title }  
  end
end