# frozen_string_literal: true

Rails.application.routes.draw do
  root to: 'home_turbo#index'

  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'

  resources :home, only: :index

  namespace :api do
    resources :home do
      get '/', to: 'home#index'
    end

    resources :users do
      get :playlists
      post '/push_notif_preference', to: 'users#create_push_notif_preference', on: :collection
      get 'player/devices', to: 'users#devices', on: :collection
      get 'player/recently_played_tracks', to: 'users#recently_played_tracks', on: :collection
    end

    resource :playlists do
      get '/my', to: 'playlists#my'
      get '/explore', to: 'playlists#explore'
      get '/subscriptions', to: 'playlists#subscriptions'
      get '/accessible', to: 'playlists#accessible'
      post '/create', to: 'playlists#create'
      get '/:id', to: 'playlists#show'
      put '/:id', to: 'playlists#update'
      get '/:id/stats', to: 'playlists#stats'
      post '/:id/add_track', to: 'playlists#add_track'
      post '/:id/subscribed', to: 'playlists#subscribed'
      post '/:id/unsubscribed', to: 'playlists#unsubscribed'
      post '/:id/play', to: 'playlists#play'
      get '/:id/recommendations', to: 'playlists#recommendations'
      get '/:id/shareable_link', to: 'playlists#shareable_link'
      get '/id_from_hash/:hash', to: 'playlists#id_from_hash'
    end

    resource :tracks, default: :json do
      get :search
      get ':id', to: 'tracks#show'
      patch ':id/up_vote', to: 'tracks#up_vote'
      patch ':id/down_vote', to: 'tracks#down_vote'
      delete ':id', to: 'tracks#delete'
    end
  end

  get '/auth/spotify/callback', to: 'auth#spotify_auth_callback'
  get '/auth/spotify_login_url', to: 'auth#spotify_login_url'
  get '/auth/user', to: 'auth#user'
  get '/auth/refresh_access_token', to: 'auth#refresh_access_token'
  post '/auth/spotify_get_token', to: 'auth#spotify_get_token'
  post '/auth/logout', to: 'auth#logout'

  # FE v2
  scope '/turbo' do
    get 'home' => 'home_turbo#index'
    get 'playlists' => 'playlists#index'
    get 'playlists/:id' => 'playlists#show'
    get 'playlists/:id/edit' => 'playlists#edit'
  end
  # Handle every other routes to home#index / Angular router
  get '*path', to: 'home#index'
end
