Rails.application.routes.draw do
  get root to: "teams#index"
  resources :teams, except: :destroy
end
