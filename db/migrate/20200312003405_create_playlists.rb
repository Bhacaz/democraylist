# frozen_string_literal: true

class CreatePlaylists < ActiveRecord::Migration[6.0]
  def change
    create_table :playlists do |t|
      t.string :spotify_id
      t.string :description
      t.string :name
      t.references :user, index: true

      t.timestamps
    end
  end
end
