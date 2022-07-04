# frozen_string_literal: true

class SendNotifJob < ApplicationJob
  def perform(notif_data, user_id)
    User.find(user_id).push_notif_preferences.each do |push_notif_preference|
      ForDeviceJob.perform_later notif_data, push_notif_preference.preference
    end
  end

  class ForDeviceJob < ApplicationJob
    retry_on Exception, attempts: 3

    def perform(notif_data, push_preference)
      NotificationService.send_push notif_data, push_preference
    end
  end
end
