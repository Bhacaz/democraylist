class Vote < ApplicationRecord
  belongs_to :user
  belongs_to :track

  enum vote: { up: 0, down: 1 }

  validates :user_id, uniqueness: { scope: :track_id }

  after_commit :sync_tracks_with_spotify

  def sync_tracks_with_spotify
    return unless track.playlist.spotify_id

    return if user_id != track.playlist.user_id

    SyncPlaylistJob.perform_later(track.playlist_id)
  end
end
