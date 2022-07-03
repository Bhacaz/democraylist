class CreateSubscriptions < ActiveRecord::Migration[6.0]
  def change
    create_table :subscriptions do |t|
      t.references :user, index: true
      t.references :playlist, index: true
      t.index %i[user_id playlist_id], unique: true

      t.timestamps
    end
  end
end
