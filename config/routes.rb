Rails.application.routes.draw do
  get root to: "teams#index"
  resources :teams, only: [:index, :new, :create]
end
