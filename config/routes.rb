Rails.application.routes.draw do
  root 'messages#index'
  resources :users
  resources :messages
  get    '/login',   to: 'sessions#new'
  post   '/login',   to: 'sessions#create'
  delete '/logout',  to: 'sessions#destroy'

  # Berlin Property Screener
  resources :properties, only: [:index, :show] do
    collection do
      get  :dashboard
      get  :recommended
      post :screen
    end
  end
  resource :search_criteria, only: [:edit, :update]

  mount ActionCable.server, at: '/cable'
end
