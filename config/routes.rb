Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

get '/' => 'home#index'

api_routes = proc do
  resources :banks, only: [:show, :index]
  resources :branches, only: [:index]
end

scope '/api/' do
  scope 'v1' do
    scope '', &api_routes
  end
end
  
end
