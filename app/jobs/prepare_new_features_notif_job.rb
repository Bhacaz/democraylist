# frozen_string_literal: true

class PrepareNewFeaturesNotifJob < ApplicationJob
  queue_as :default

  def perform(body)
    NotificationService.broadcast_new_features(body)
  end
end
