# frozen_string_literal: true

class Playlist < ApplicationRecord
  DEFAULT_IMAGE_URL = 'https://cdn.icon-icons.com/icons2/2463/PNG/512/playlist_icon_149195.png'

  belongs_to :user
  enum share_setting: { visible: 0, with_link: 1, restricted: 2 }

  validates :name, presence: true
  validates :spotify_id, uniqueness: true, presence: true
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

  def self.home_playlists(user, search: nil) # rubocop:disable Metrics/AbcSize
    query = where(user: user)
            .left_joins(:tracks, :subscriptions)
            .or(
              where(id: Playlist.joins(:subscriptions).merge(Subscription.where(user: user)).select(:id))
            )
            .group('playlists.id')
            .pluck(
              'playlists.id',
              'playlists.created_at',
              'MAX(tracks.created_at)',
              'MAX(subscriptions.created_at)'
            )

    query.each do |list|
      list.map! do |item|
        item.is_a?(String) ? Time.zone.parse(item) : item
      end
    end

    query = query.sort_by do |_playlist_id, playlist_created_at, max_track_created_at, max_subscription_created_at|
      -[playlist_created_at.to_i, max_track_created_at.to_i, max_subscription_created_at.to_i].compact.max
    end
    ids_ordered = query.map(&:first)
    query = where(id: ids_ordered)
    query = query.where('name LIKE ?', "%#{search}%") if search.present?
    query.sort_by { |playlist| ids_ordered.index(playlist.id) }
  end

  def image_url
    fetch_image_url || DEFAULT_IMAGE_URL
  end

  private

  def fetch_image_url
    return unless spotify_id

    image_url = Rails.cache.read("playlist-image_#{spotify_id}")

    return image_url if image_url

    image_url = RSpotify::Playlist.find_by_id(spotify_id).images.first&.fetch('url')
    Rails.cache.write("playlist-image_#{spotify_id}", image_url, expires_in: 5.minutes)
    image_url
  rescue StandardError
    nil
  end
end
