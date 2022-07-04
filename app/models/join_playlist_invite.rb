# frozen_string_literal: true

class JoinPlaylistInvite < ApplicationRecord
  belongs_to :invited_by, class_name: :user, foreign_key: :invited_by_id
  belongs_to :user
  belongs_to :playlist
end
