# frozen_string_literal: true

class Playlist < ApplicationRecord
  belongs_to :user
  enum share_setting: { visible: 0, with_link: 1, restricted: 2 }

  validates :name, presence: true
  has_many :tracks, dependent: :destroy
  has_many :subscriptions, dependent: :destroy

  def preload_tracks
    @preload_tracks ||= tracks.loaded? ? tracks : tracks.includes(:votes, :user)
  end

  def real_tracks
    @real_tracks ||= begin
      positive_tracks = preload_tracks.to_a
      positive_tracks.select! { |track| track.vote_score.positive? }
      # 1. Look for must upvote
      # 2. Tie breaker: look for must downvote
      # 3. Tie breaker: most recent out is out
      positive_tracks.sort_by! do |track|
        [-track.vote_score, track.down_counts, track.votes.max_by(&:updated_at)&.updated_at&.to_i || 1]
      end
      positive_tracks.first(song_size)
    end
  end

  def archived_tracks(auth_user_id)
    real_track_ids = real_tracks.map(&:id)
    preload_tracks.to_a.select do |track|
      next false if real_track_ids.include? track.id

      track.votes.to_a.any? { |vote| vote.user_id == auth_user_id }
    end
  end

  def submission_tracks(auth_user_id)
    real_track_ids = real_tracks.map(&:id).to_set
    preload_tracks.to_a.select do |track|
      next false if real_track_ids.include? track.id

      track.votes.to_a.none? { |vote| vote.user_id == auth_user_id }
    end
  end

  def unvoted_tracks(auth_user_id)
    tracks.where.not(id: Vote.where(track_id: tracks.select(:id), user_id: auth_user_id).select(:track_id))
  end

  def image_url
    return unless spotify_id

    Rails.cache.fetch("playlist-image_#{spotify_id}", expires_in: 5.minutes) do
      RSpotify::Playlist.find_by_id(spotify_id).images.first&.fetch('url') # rubocop:disable Rails/DynamicFindBy
    end
  rescue StandardError
    update! spotify_id: nil
    nil
  end
end
