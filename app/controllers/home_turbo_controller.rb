# frozen_string_literal: true

class HomeTurboController < ApplicationTurboController
  def index
    @playlists = Playlist.home_playlists(auth_user, search: params[:query])
    @menu_items =

    respond_to do |format|
      format.html do |variant|
        variant.turbo_frame { render partial: 'playlists' }
      end
    end
  end
end
