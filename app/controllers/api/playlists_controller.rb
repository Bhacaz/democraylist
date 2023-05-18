# frozen_string_literal: true

module Api
  class PlaylistsController < ApplicationApiController
    INDEX_EXCLUDED_ATTRIBUTES = %i[tracks tracks_unvoted tracks_archived].freeze

    def my
      attributes = PlaylistSerializer.attributes_to_serialize.map(&:key) - INDEX_EXCLUDED_ATTRIBUTES
      query = Playlist.includes(:subscriptions, :user,
                                tracks: %i[votes user]).where(user_id: auth_user.id).order(created_at: :desc)
      render json: PlaylistSerializer.new(query, fields: attributes, params: { auth_user_id: auth_user.id })
    end

    def show
      playlist = Playlist.includes(:subscriptions, :user, tracks: %i[votes user]).find(params[:id])
      render json: PlaylistSerializer.new(playlist, params: { auth_user_id: auth_user.id })
    end

    def create
      new_playlist = Playlist.create! user_id: auth_user.id, **playlist_params
      spotify_playlist = RSpotify::User.find(auth_user.spotify_id).create_playlist!(playlist_params[:name], public: true,
                                                                                                            description: playlist_params[:description])
      new_playlist.update! spotify_id: spotify_playlist.id

      playlist = Playlist.includes(:subscriptions, tracks: %i[votes user]).find(new_playlist.id)

      render json: PlaylistSerializer.new(playlist, params: { auth_user_id: auth_user.id })
    end

    def update
      playlist = Playlist.includes(:subscriptions, tracks: %i[votes user]).find(params[:id])
      playlist.update!(params.require(:playlist).permit(:name, :description, :song_size, :share_setting))
      auth_user.rspotify_user
      RSpotify::Playlist
        .find_by_id(playlist.spotify_id)
        .change_details!(
          **Hashie::Mash.new(name: playlist.name,
                             description: playlist.description)
        )

      render json: PlaylistSerializer.new(playlist, params: { auth_user_id: auth_user.id })
    end

    def add_track
      playlist = Playlist.includes(:subscriptions, tracks: %i[votes user]).find(params[:id])
      playlist.tracks.create! playlist_id: params[:id], added_by_id: auth_user.id, spotify_id: params[:track_id]

      render json: PlaylistSerializer.new(playlist, params: { auth_user_id: auth_user.id })
    end

    def explore
      # TODO: add algo to fetch the most popular playlist be subcriptionsx
      attributes = PlaylistSerializer.attributes_to_serialize.map(&:key) - INDEX_EXCLUDED_ATTRIBUTES
      subscription_ids = Playlist.joins(:subscriptions, :user).merge(Subscription.where(user_id: auth_user.id)).ids
      query = Playlist.includes(:subscriptions, :user,
                                tracks: %i[votes user]).where.not(user_id: auth_user.id).where.not(id: subscription_ids).where(share_setting: :visible)
      render json: PlaylistSerializer.new(query, fields: attributes, params: { auth_user_id: auth_user.id })
    end

    def subscriptions
      attributes = PlaylistSerializer.attributes_to_serialize.map(&:key) - INDEX_EXCLUDED_ATTRIBUTES
      query = Playlist.includes(:subscriptions, :user,
                                tracks: %i[votes user]).joins(:subscriptions).merge(Subscription.where(user_id: auth_user.id)).order(created_at: :desc)
      render json: PlaylistSerializer.new(query, fields: attributes, params: { auth_user_id: auth_user.id })
    end

    def accessible
      track_id = params[:track_id]
      playlist_ids_with_track = Track.where(spotify_id: track_id).distinct.pluck(:playlist_id) if track_id
      attributes = PlaylistSerializer.attributes_to_serialize.map(&:key) - INDEX_EXCLUDED_ATTRIBUTES
      my_playlist_ids = Playlist.where(user_id: auth_user.id).ids
      subscription_ids = Playlist.joins(:subscriptions).merge(Subscription.where(user_id: auth_user.id)).ids
      playlist_ids = my_playlist_ids.concat(subscription_ids) - playlist_ids_with_track
      query = Playlist.includes(:subscriptions, :user,
                                tracks: %i[votes user]).where(id: playlist_ids).order(created_at: :desc)
      render json: PlaylistSerializer.new(query, fields: attributes, params: { auth_user_id: auth_user.id })
    end

    def subscribed
      playlist = Playlist.includes(:subscriptions, tracks: %i[votes user]).find(params[:id])
      Subscription.create! user_id: auth_user.id, playlist_id: playlist.id
      RSpotify::User.find(auth_user.spotify_id).follow(RSpotify::Playlist.find_by_id(playlist.spotify_id))
      attributes = PlaylistSerializer.attributes_to_serialize.map(&:key) - INDEX_EXCLUDED_ATTRIBUTES
      render json: PlaylistSerializer.new(playlist, fields: attributes, params: { auth_user_id: auth_user.id })
    end

    def unsubscribed
      playlist = Playlist.includes(:subscriptions, tracks: %i[votes user]).find(params[:id])
      Subscription.find_by!(user_id: auth_user.id, playlist_id: playlist.id).destroy!
      RSpotify::User.find(auth_user.spotify_id).unfollow(RSpotify::Playlist.find_by_id(playlist.spotify_id))
      attributes = PlaylistSerializer.attributes_to_serialize.map(&:key) - INDEX_EXCLUDED_ATTRIBUTES
      render json: PlaylistSerializer.new(playlist, fields: attributes, params: { auth_user_id: auth_user.id })
    end

    def stats
      playlist = Playlist.includes(tracks: [:user, { votes: :user }]).find(params[:id])

      implicated_users = playlist.tracks.map(&:user)
      implicated_users.concat(playlist.tracks.flat_map { |track| track.votes.map(&:user) })
      implicated_users.concat(playlist.subscriptions.map(&:user))
      implicated_users << playlist.user
      implicated_users.uniq!

      rspotify_user = implicated_users.map { |user| RSpotify::User.find(user.spotify_id) }.index_by(&:id)

      stats = implicated_users.map do |user|
        hash = {}
        hash[:user] = rspotify_user[user.spotify_id].as_json.merge(user.as_json)
        hash[:user].delete('access_token')
        hash[:user].delete('refresh_token')
        hash[:submission_count] = playlist.tracks.count { |track| track.added_by_id == user.id }
        hash[:submission_upvote_count] = playlist.tracks.select do |track|
                                           track.added_by_id == user.id
                                         end.sum { |track| track.votes.up.size }
        hash[:submission_downvote_count] = playlist.tracks.select do |track|
                                             track.added_by_id == user.id
                                           end.sum { |track| track.votes.down.size }
        hash[:upvote_count] = playlist.tracks.flat_map do |track|
                                track.votes.up
                              end.count { |vote| vote.user_id == user.id }
        hash[:downvote_count] = playlist.tracks.flat_map do |track|
                                  track.votes.down
                                end.count { |vote| vote.user_id == user.id }
        hash
      end

      stats.sort_by! { |stat| -stat[:submission_count] }

      stats << {
        user: { display_name: 'Total' },
        submission_count: stats.sum { |stat| stat[:submission_count] },
        submission_upvote_count: stats.sum { |stat| stat[:submission_upvote_count] },
        submission_downvote_count: stats.sum { |stat| stat[:submission_downvote_count] },
        upvote_count: stats.sum { |stat| stat[:upvote_count] },
        downvote_count: stats.sum { |stat| stat[:downvote_count] }
      }

      render json: stats
    end

    def play
      playlist = Playlist.find(params[:id])
      uris =
        case params[:queue]
        when 'tracks'
          playlist.real_tracks.map(&:uri)
        when 'submissions'
          playlist.submission_tracks(auth_user.id).map(&:uri)
        when 'unvoted'
          Track.includes(:votes)
               .where(playlist_id: params[:id])
               .reject { |track| track.votes.map(&:user_id).include?(auth_user.id) }
               .map(&:uri)
        when 'upvoted'
          Vote.joins(track: :playlist)
              .includes(:track)
              .where(user_id: auth_user.id, vote: :up)
              .merge(Playlist.where(id: playlist.id))
              .map { |vote| vote.track.uri }
        when 'downvoted'
          Vote.joins(track: :playlist)
              .includes(:track)
              .where(user_id: auth_user.id, vote: :down)
              .merge(Playlist.where(id: playlist.id))
              .map { |vote| vote.track.uri }
        else
          render json: :error, status: :not_found
        end
      RSpotify::Player.new(auth_user.rspotify_user).play_tracks(uris)
      render json: :ok
    end

    def recommendations
      seeds = Playlist.find(params[:id]).real_tracks.first(10).sample(5).map(&:spotify_id)
      options = {
        min_energy: 0.5,
        min_danceability: 0.5,
        max_popularity: 80
      }
      render json: RSpotify::Recommendations.generate(limit: 10, seed_tracks: seeds, **options).tracks
    end

    def shareable_link
      playlist = Playlist.find(params[:id])
      if playlist.share_setting == 'restricted'
        render head: 404
      else
        render json: { hash: HashService.hash(playlist.id) }
      end
    end

    def id_from_hash
      render json: { id: HashService.un_hash(params[:hash]) }
    end

    private

    def playlist_params
      params.require(:playlist).permit(:user_id, :name, :description, :song_size)
    end
  end
end
