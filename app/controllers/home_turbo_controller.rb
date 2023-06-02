class HomeTurboController < ApplicationController
  layout "application_turbo"

  def index
    @playlists = Playlist.all
  end
end
