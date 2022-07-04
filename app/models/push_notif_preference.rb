# frozen_string_literal: true

class PushNotifPreference < ApplicationRecord
  belongs_to :user

  serialize :preference, Hash
  validates :preference, uniqueness: { scope: :user_id }
end
