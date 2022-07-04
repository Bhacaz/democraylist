# frozen_string_literal: true

class SyncPlaylistJob < ApplicationJob
  queue_as :default
  retry_on Exception, attempts: 3

  def perform(playlist_id)
    playlist = Playlist.includes(tracks: :votes).find(playlist_id)
    return unless playlist.spotify_id

    # Init @@users_credentials by calling rspotify_user
    playlist.user.rspotify_user
    r_playlist = RSpotify::Playlist.find(playlist.user.spotify_id, playlist.spotify_id)
    r_playlist.replace_tracks!(playlist.real_tracks)
  end
end
