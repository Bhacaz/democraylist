# frozen_string_literal: true

class PlaylistSerializer
  include BrightSerializer::Serializer

  attributes(*Playlist.attribute_names.map(&:to_sym))

  attribute :image_url

  attribute :uri do |object|
    "spotify:playlist:#{object.spotify_id}"
  end

  attribute :created_by do |object|
    {
      id: object.user_id,
      display_name: object.user.name,
      spotify_id: object.user.spotify_id
    }
  end

  attribute :subscribed do |object, params|
    object.subscriptions.any? { |subscription| subscription.user_id == params[:auth_user_id] }
  end

  attribute :subscribers do |object|
    object.subscriptions.size
  end

  attribute :tracks_count do |object|
    object.real_tracks.size
  end

  attribute :tracks do |object, params|
    tracks = object.real_tracks
    next [] if tracks.empty?

    tracks_data = RSpotify::Track.find(tracks.map(&:spotify_id)).index_by(&:id)
    tracks.map do |track|
      tracks_data[track.spotify_id].as_json.merge!(TrackSerializer.new(track, params: params).to_hash)
    end
  end

  attribute :tracks_unvoted do |object, params|
    tracks = object.unvoted_tracks(params[:auth_user_id]).includes(:user, :votes)
    next [] if tracks.empty?

    tracks_data = RSpotify::Track.find(tracks.map(&:spotify_id)).index_by(&:id)
    tracks.map do |track|
      tracks_data[track.spotify_id].as_json.merge!(TrackSerializer.new(track, params: params).to_hash)
    end
  end

  attribute :tracks_unvoted_count do |object, params|
    object.unvoted_tracks(params[:auth_user_id]).size
  end

  attribute :tracks_archived do |object, params|
    tracks = object.archived_tracks(params[:auth_user_id])
    next [] if tracks.empty?

    tracks_data = RSpotify::Track.find(tracks.map(&:spotify_id)).index_by(&:id)
    tracks.map do |track|
      tracks_data[track.spotify_id].as_json.merge!(TrackSerializer.new(track, params: params).to_hash)
    end
  end

  attribute :tracks_archived_count do |object, params|
    object.archived_tracks(params[:auth_user_id]).size
  end
end
