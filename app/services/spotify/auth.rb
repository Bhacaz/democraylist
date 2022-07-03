require 'httparty'

module Spotify
  class Auth
    AuthTokens = Struct.new(:token, :refresh_token, :expires_at, :expires)

    def self.me(access_token, credentials = nil); end
  end
end
