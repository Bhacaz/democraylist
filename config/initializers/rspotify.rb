
return unless ENV['spotify_client_id']

RSpotify::authenticate(ENV['spotify_client_id'], ENV['spotify_client_secret'])

require_relative '../../app/lib/r_spotify/track_extension'
