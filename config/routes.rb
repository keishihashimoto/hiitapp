Rails.application.routes.draw do
  devise_for :users
  get root to: "teams#index"
  resources :teams, except: :destroy
end
