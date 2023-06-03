# frozen_string_literal: true

class HomeTurboController < ApplicationController
  layout 'application_turbo'

  def index
    @playlists =
      if params[:query].present?
        Playlist.where('name LIKE ?', "%#{params[:query]}%")
      else
        Playlist.all
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
