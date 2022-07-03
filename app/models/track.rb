class Track < ApplicationRecord
  belongs_to :playlist
  belongs_to :user, foreign_key: :added_by_id
  has_many :votes, dependent: :destroy

  validates :playlist_id, presence: true
  validates :added_by_id, presence: true
  validates :spotify_id, uniqueness: { scope: :playlist_id }

  after_commit :send_notification, on: :create

  def vote_score
    votes.to_a.count(&:up?)
  end

  def down_counts
    votes.to_a.count(&:down?)
  end

  def uri
    "spotify:track:#{spotify_id}"
  end

  def send_notification
    PrepareNewTrackNotifJob.perform_later(id)
  end
end
