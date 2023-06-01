class HomeTurboController < ApplicationController

  def index
    @playlists = Playlist.all
  end
end
