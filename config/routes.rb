Rails.application.routes.draw do
  devise_for :users
  get root to: "teams#index"
  resources :teams, except: :destroy
  resources :users, only: [:show, :destroy]
  get "teams/users/:id", to: "users#index"
  resources :menus, except: [:index]
end