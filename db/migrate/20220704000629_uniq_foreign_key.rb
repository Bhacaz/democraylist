# frozen_string_literal: true

class UniqForeignKey < ActiveRecord::Migration[7.0]
  def change
    change_table :tracks do |t|
      t.remove_index :playlist_id
    end

    add_index :tracks, %i[playlist_id spotify_id], unique: true
    add_index :users, :spotify_id, unique: true

    change_table :votes do |t|
      t.remove_index :track_id
    end
    add_index :votes, %i[track_id user_id], unique: true
  end
end
