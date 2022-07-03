return unless ENV['spotify_client_id']

RSpotify.authenticate(ENV.fetch('spotify_client_id', nil), ENV.fetch('spotify_client_secret', nil))

require_relative '../../app/lib/r_spotify/track_extension'
