# frozen_string_literal: true

module ApplicationHelper
  def spotify_user
    @spotify_user ||= RSpotify::User.find(auth_user.spotify_id)
  end

  def auth_user
    @auth_user ||=
      begin
        user = User.find(session[:current_user_id])
        return unless user # Return nil if no user is found

        update_rspotify_users_credentials(user)
        user
      end
  end

  def authenticate_request
    head :forbidden if session[:current_user_id].nil? || session[:access_token].nil?
  end

  private

  def update_rspotify_users_credentials(user)
    # Set the class variable if it's not defined it can be undefined
    # if the server was restarted and the user was already logged in
    unless RSpotify::User.class_variable_defined?(:@@users_credentials)
      RSpotify::User.class_variable_set(:@@users_credentials, {})
    end

    user_credentials = RSpotify::User.class_variable_get(:@@users_credentials)
    user_credentials[user.spotify_id] ||= {}
    user_credentials[user.spotify_id]['token'] ||= session[:access_token]
  end
end
