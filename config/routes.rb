Rails.application.routes.draw do
  devise_for :users
  # custom routes
  get "next_up", to: "users#next_up", as: "next_up"
  get "stats", to: "users#stats", as: "stats"

  root to: "pages#home"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
  get "likes", to: "pages#likes"

  resources :reviews, only: [:index]
  resources :collections, only: [:index, :destroy] do
    member do
      get :create_from_card
    end
  end

  resources :chats, only: [:show, :index] do
    resources :messages, only: [:create]
  end

  resources :media, only: [:show, :index] do
    resources :reviews, only: [:new, :create]
    resources :chats, only: [:create]
    resources :collections, only: [:create]

    member do
      get :reviews
      get :toggle_next_up
      get :toggle_likes
    end

    collection do
      get :toggle_settings
      post :create_record
      get :search
      post :search
    end
  end
end
