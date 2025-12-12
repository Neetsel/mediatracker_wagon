Rails.application.routes.draw do
  devise_for :users

  root to: "pages#home"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
  get "next_up", to: "collections#next_up"
  get "likes", to: "pages#likes"

  resources :reviews, only: [:index]
  resources :collections, only: [:index]

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
      post :create_from_omdb
      post :search_from_omdb
      post :create_from_igdb
      post :search_from_igdb
      post :create_from_open_library
      post :search_from_open_library
    end
  end
end
