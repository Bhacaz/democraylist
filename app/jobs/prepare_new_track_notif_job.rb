# frozen_string_literal: true

class PrepareNewTrackNotifJob < ApplicationJob
  queue_as :default

  def perform(track_id)
    NotificationService.broadcast_added_track(Track.find(track_id))
  end
end
