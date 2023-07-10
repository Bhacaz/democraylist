# frozen_string_literal: true

class HomeTurboController < ApplicationTurboController
  def index
    @playlists = Playlist.home_playlists(auth_user, search: params[:query])
    @menu_items = MenuHelper.items(
      ['logout', 'Logout', auth_logout_path]
    )

    respond_to do |format|
      format.html do |variant|
        variant.turbo_frame { render partial: 'playlists' }
      end
    end
  end
end
