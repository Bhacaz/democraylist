# frozen_string_literal: true

class CreatePlaylistShareSetting < ActiveRecord::Migration[6.0]
  def change
    add_column :playlists, :share_setting, :integer, default: 0

    create_table :join_playlist_invites do |t|
      t.references :invited_by, index: true, foreign_key: { to_table: :users }
      t.references :user, index: true
      t.references :playlist

      t.timestamps
    end

    Playlist.update_all share_setting: :with_link # rubocop:disable Rails/SkipsModelValidations
  end
end
