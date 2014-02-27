SyncExample::Application.routes.draw do
  
  devise_for :users

  devise_scope :user do 
    authenticated :user do
      root to: 'projects#index'
    end
    unauthenticated :user do
      root :to => 'devise/sessions#new'
    end
  end

  concern :site do
    resources :projects do
      collection do
        get 'status/:status' => 'projects#index'
      end
      get :refetch, on: :collection
      resources :todos do
        resources :comments
      end
    end
  end

  concerns :site

  namespace :admin do
    concerns :site
  end

  resources :users
end
