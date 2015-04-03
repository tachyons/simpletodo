Todo::Application.routes.draw do
  root :to => "tasks#index"
  resources :user_sessions
  get '/auth/:provider/callback', to: 'sessions#create'
  # resources :friendships do
  #   delete :delete
  # end
  resources :users do
    collection do
      get :logout
      get :forgot_password
      post :forgot_password
      get :change_password
      post :change_password
      get :login
      post :login
    end
  end

  resources :tasks do
    resources :comments
    collection do
      post :share_task
      put :change_progress
      post :change_progress
      delete :delete_share
      put :move_up
      post :move_up
      put :move_down
      post :move_down
      get :task_list
      get :get_task_delete_confirm
      put :change_status
      post :change_status
    end
  end
  resource :user_sessions
  resources :user_verifications, :only => [:show]
  resources :password_resets, :only => [:new, :create, :edit, :update]
  match '/' => 'tasks#index'
  match '/:controller(/:action(/:id))'
  match 'login' => 'user_sessions#new', :as => :login
  match 'logout' => 'user_sessions#destroy', :as => :logout
end
