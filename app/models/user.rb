# frozen_string_literal: true

class User < ApplicationRecord
  has_many :playlists, dependent: :destroy
  has_many :votes, dependent: :destroy
  has_many :subscriptions, dependent: :destroy
  has_many :tracks, foreign_key: :added_by_id, dependent: :destroy, inverse_of: :user
  has_many :push_notif_preferences, dependent: :destroy
  has_many :added_tracks, class_name: 'Track', foreign_key: :added_by_id, inverse_of: :added_by, dependent: :destroy
  validates :spotify_id, presence: true, uniqueness: true

  def rspotify_user
    RSpotify::User.new('id' => spotify_id,
                       'credentials' => { 'token' => access_token,
                                          'refresh_token' => refresh_token })
  end

  def image_url
    digest_access_token = ActiveSupport::Digest.hexdigest(access_token)
    Rails.cache.fetch("user/#{digest_access_token}/image_url", expires_in: 1.day) do
      RSpotify::User.find(spotify_id).images.first['url']
    end
  end
end
