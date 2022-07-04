# frozen_string_literal: true

require 'httparty'

class AuthController < ApplicationApiController
  skip_before_action :authenticate_request, except: %i[user refresh_access_token]

  def login; end

  def logout
    User.find(auth_user.id).update! access_token: nil, expires_at: nil, refresh_token: nil
    session[:current_user_id] = nil
    session[:access_token] = nil
    render json: :ok
  end

  def spotify_login_url
    query_params = {
      response_type: 'code',
      client_id: ENV.fetch('spotify_client_id', nil),
      scope: 'user-read-email playlist-read-private playlist-read-collaborative playlist-modify-private playlist-modify-public user-read-playback-state user-modify-playback-state user-read-recently-played',
      redirect_uri: "#{request.protocol}#{request.host_with_port}/auth/spotify/callback"
    }

    render json: { url: "https://accounts.spotify.com/authorize?#{query_params.to_query}" }
  end

  def spotify_auth_callback
    # Get token from code
    body = {
      grant_type: 'authorization_code',
      code: params[:code],
      redirect_uri: "#{ENV.fetch('democraylist_host', nil)}/auth/spotify/callback",
      client_id: ENV.fetch('spotify_client_id', nil),
      client_secret: ENV.fetch('spotify_client_secret', nil)
    }

    response = ::HTTParty.post(
      'https://accounts.spotify.com/api/token',
      headers: { 'Content-Type' => 'application/x-www-form-urlencoded' },
      body: body.to_query
    )

    access_token = response['access_token']
    expires_at = response['expires_in'] + Time.now.to_i

    credentials = Hashie::Mash.new(
      token: access_token,
      refresh_token: response['refresh_token'],
      expires_at: expires_at,
      expires: true
    )

    response = HTTParty.get(
      'https://api.spotify.com/v1/me',
      headers: { 'Authorization' => "Bearer #{access_token}" }
    )

    user = User.find_or_initialize_by(spotify_id: response['id'])
    user.email = response['email']
    user.name = response['display_name']
    user.access_token = access_token
    user.refresh_token = credentials['refresh_token']
    user.expires_at = expires_at
    user.save!

    RSpotify::User.new(**Hashie::Mash.new(response), 'credentials' => credentials)

    # Every time the owner of the playlist login sync own playlists
    user.playlists.each { |playlist| SyncPlaylistJob.perform_later(playlist.id) }
    session[:current_user_id] = user.id
    session[:access_token] = access_token
    redirect_to root_path
  end

  def user
    render json: { user: spotify_user.as_json.merge(auth_user.as_json) }
  end

  def refresh_access_token
    access_token = RSpotify::User.send(:refresh_token, auth_user.rspotify_user.id)
    User.find_by!(spotify_id: auth_user.spotify_id).update!(access_token: access_token,
                                                            expires_at: 1.hour.from_now.to_i)

    render json: { access_token: access_token }
  end
end
