# frozen_string_literal: true

class Subscription < ApplicationRecord
  belongs_to :user
  belongs_to :playlist

  validates :user_id, uniqueness: { scope: :playlist_id }
end
