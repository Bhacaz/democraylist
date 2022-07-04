# frozen_string_literal: true

module Api
  class TracksController < ApplicationApiController
    def search
      if params[:q]
        limit = params[:limit] || 5
        render json: RSpotify::Track.search(params[:q], limit: limit)
      elsif params[:track_id]
        begin
          render json: RSpotify::Track.find(params[:track_id])
        rescue StandardError
          render json: :error, status: :not_found
        end
      end
    end

    def show
      render json: RSpotify::Track.find(params[:id])
    end

    def up_vote
      vote = Vote.find_or_initialize_by(track_id: params[:id], user_id: auth_user.id)
      vote.vote = :up
      vote.save!
      render json: vote
    end

    def down_vote
      vote = Vote.find_or_initialize_by(track_id: params[:id], user_id: auth_user.id)
      vote.vote = :down
      vote.save!
      render json: vote
    end

    def delete
      Track.find(params[:id]).destroy!
    end
  end
end
