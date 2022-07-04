# frozen_string_literal: true

class AddPlaylistsSize < ActiveRecord::Migration[6.0]
  def change
    add_column :playlists, :song_size, :integer
  end
end
