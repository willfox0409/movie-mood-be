Rails.application.routes.draw do
  
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    get 'v1/Recommendations'
    namespace :v1 do
      post '/login', to: 'sessions#create'
      post '/recommendation', to: 'recommendations#create'
    end
  end
end
