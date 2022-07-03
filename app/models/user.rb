class User < ApplicationRecord
  validates :spotify_id, presence: true, uniqueness: true
  has_many :playlists, dependent: :destroy
  has_many :votes, dependent: :destroy
  has_many :subscriptions, dependent: :destroy
  has_many :tracks, foreign_key: :added_by_id, dependent: :destroy
  has_many :push_notif_preferences, dependent: :destroy

  def rspotify_user
    RSpotify::User.new('id' => spotify_id,
                       'credentials' => { 'token' => access_token,
                                          'refresh_token' => refresh_token })
  end
end
