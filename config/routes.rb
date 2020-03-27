Rails.application.routes.draw do
  root 'auth#login'

  resources :users do
    get :playlists
  end

  resource :playlists do
    get '/', to: 'playlists#index'
    post '/create', to: 'playlists#create'
    get '/:id', to: 'playlists#show'
    post '/:id/add_track', to: 'playlists#add_track'
  end
  
  resource :tracks, default: :json do
    get :search
    get ':id', to: 'tracks#show'
  end

  get '/auth/spotify/callback', to: 'auth#spotify'
  get '/auth/spotify_login_url', to: 'auth#spotify_login_url'
  get '/auth/user', to: 'auth#user'
  post '/auth/spotify_get_token', to: 'auth#spotify_get_token'

  get '/login', to: 'auth#login'

  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
