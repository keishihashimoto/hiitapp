Rails.application.routes.draw do
  devise_for :users
  get root to: "teams#index"
  resources :teams, except: :destroy
  resources :users, only: [:show, :destroy]
  resources :users do
    member do
      get "detail"
    end
  end
  resources :menus, except: [:index]
  resources :hiits, except: [:index]
  resources :groups, except: [:index]
  resources :hiits do
    resources :groups do
      collection do
        get "new_restricted"
      end
    end
    resources :user_hiits, only: [:create]
  end
  resources :user do
    resources :user_hiits, only: [:index]
  end
end