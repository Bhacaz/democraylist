# frozen_string_literal: true

class TrackTable < ActiveRecord::Migration[6.0]
  def change
    create_table :tracks do |t|
      t.string :spotify_id
      t.references :playlist, index: true
      t.references :added_by, index: true, foreign_key: { to_table: :users }

      t.timestamps
    end

    create_table :votes do |t|
      t.string :spotify_id
      t.references :track, index: true
      t.references :user, index: true
      t.integer :vote

      t.timestamps
    end
  end
end
