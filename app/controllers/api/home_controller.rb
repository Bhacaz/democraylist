module Api
  class HomeController < ApplicationApiController
    def index
      playlist_subscrib_ids = Playlist.joins(:subscriptions).merge(Subscription.where(user_id: auth_user.id)).ids
      my_playlist_ids = Playlist.where(user_id: auth_user.id).ids

      query = Playlist.where(id: playlist_subscrib_ids.concat(my_playlist_ids))
                      .includes(:tracks)

      query = query.where('name LIKE ?', "%#{params[:q]}%") if params[:q]
      query = query.sort_by do |playlist|
        -(playlist&.tracks&.map { |track| track.created_at.to_i }.max || playlist.created_at.to_i)
      end
      data = query.map do |playlist|
        { id: playlist.id, name: playlist.name, image_url: playlist.image_url }
      end
      render json: data
    end
  end
end
