# frozen_string_literal: true
# require 'rspotify/oauth'
#
# module SpotifyOmniauthExtension
#   extend ActiveSupport::Concern
#
#   def callback_url
#     full_host + script_name + callback_path
#   end
# end
#
# Rails.application.config.to_prepare do
#   OmniAuth::Strategies::Spotify.include SpotifyOmniauthExtension
# end
#
# Rails.application.config.middleware.use OmniAuth::Builder do
#   provider :spotify,
#            ENV['spotify_client_id'],
#            ENV['spotify_client_secret'],
#            scope: 'user-read-email playlist-read-private playlist-read-collaborative user-library-read user-library-modify'
# end
