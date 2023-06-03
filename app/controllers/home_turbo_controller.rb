class HomeTurboController < ApplicationController
  layout "application_turbo"

  def index
    @playlists = Playlist.all
    @menu_items = MenuHelper.items(
      ['logout', 'Logout', auth_logout_path]
    )
  end
end
