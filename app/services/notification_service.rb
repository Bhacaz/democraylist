# frozen_string_literal: true

class NotificationService
  def self.broadcast_added_track(track)
    user_ids = track.playlist.subscriptions.map(&:user_id) << track.playlist.user_id
    user_ids.delete(track.added_by_id)

    message = build_new_track_message(track)
    User.joins(:push_notif_preferences).where(id: user_ids).distinct.each do |user|
      SendNotifJob.perform_later(message, user.id)
    end
  end

  def self.broadcast_new_features(body)
    message = build_new_feature_message(body)
    User.joins(:push_notif_preferences).distinct.each do |user|
      SendNotifJob.perform_later(message, user.id)
    end
  end

  def self.send_push(message, notification_data)
    Webpush.payload_send(endpoint: notification_data['endpoint'],
                         message: message.to_json,
                         p256dh: notification_data['keys']['p256dh'],
                         auth: notification_data['keys']['auth'],
                         ttl: 24 * 60 * 60,
                         vapid: {
                           subject: 'mailto:admin@democraylist.com',
                           public_key: ENV.fetch('push_public_key', nil),
                           private_key: ENV.fetch('push_private_key', nil)
                         })
  end

  def self.build_new_track_message(track)
    badge = "#{ENV.fetch('democraylist_host', nil)}/icons/icon-512x512-white.png"
    icon = RSpotify::Track.find(track.spotify_id).album.images.last['url']
    user_name = track.user.name
    rspotify_track = RSpotify::Track.find(track.spotify_id)
    playlist_name = track.playlist.name
    title = "Democraylist - #{playlist_name}"
    body = "#{rspotify_track.name} - #{rspotify_track.artists.map(&:name).join(', ')}\nAdded by #{user_name}"

    # Link to song in playlist
    url = ENV.fetch('democraylist_host', nil) + "/playlists/#{track.playlist_id}?track_id=#{track.id}"
    {
      notification: {
        icon: icon,
        badge: badge,
        title: title,
        body: body,
        vibrate: [200, 100, 200],
        data: { url: url }
      }
    }
  end

  def self.build_new_feature_message(body)
    badge = "#{ENV.fetch('democraylist_host', nil)}/icons/icon-512x512-white.png"
    title = 'Democraylist - NEW FEATURES!'

    # Link to song in playlist
    url = ENV.fetch('democraylist_host', nil)
    {
      notification: {
        badge: badge,
        title: title,
        body: body,
        vibrate: [200, 100, 200],
        data: { url: url }
      }
    }
  end
end
