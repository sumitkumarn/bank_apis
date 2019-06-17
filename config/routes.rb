Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

get '/' => 'home#index'

resources :users, param: :_username
post '/auth/login', to: 'authentication#login'

api_routes = proc do
  resources :branches, only: [:index,:show]
end

scope '/api/' do
  scope 'v1' do
    scope '', &api_routes
  end
end
  
end
