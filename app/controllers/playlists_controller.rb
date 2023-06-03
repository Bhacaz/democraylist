class PlaylistsController < ApplicationController
  layout 'application_turbo'
  def index
    @playlists = Playlist.all
  end

  def show
  end

  def edit
  end
end
