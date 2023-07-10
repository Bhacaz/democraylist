# frozen_string_literal: true

class HomeTurboController < ApplicationTurboController
  def index
    @playlists =
      if params[:query].present?
        Playlist.home_playlists(auth_user).where('name LIKE ?', "%#{params[:query]}%")
      else
        Playlist.home_playlists(auth_user)
      end
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
