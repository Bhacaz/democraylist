# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_04_26_015942) do

  create_table "playlists", force: :cascade do |t|
    t.string "spotify_id"
    t.string "description"
    t.string "name"
    t.integer "user_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "song_size"
    t.index ["user_id"], name: "index_playlists_on_user_id"
  end

  create_table "push_notif_preferences", force: :cascade do |t|
    t.integer "user_id"
    t.string "preference"
    t.index ["user_id"], name: "index_push_notif_preferences_on_user_id"
  end

  create_table "subscriptions", force: :cascade do |t|
    t.integer "user_id"
    t.integer "playlist_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["playlist_id"], name: "index_subscriptions_on_playlist_id"
    t.index ["user_id", "playlist_id"], name: "index_subscriptions_on_user_id_and_playlist_id", unique: true
    t.index ["user_id"], name: "index_subscriptions_on_user_id"
  end

  create_table "tracks", force: :cascade do |t|
    t.string "spotify_id"
    t.integer "playlist_id"
    t.integer "added_by_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["added_by_id"], name: "index_tracks_on_added_by_id"
    t.index ["playlist_id"], name: "index_tracks_on_playlist_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "spotify_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "access_token"
    t.integer "expires_at"
  end

  create_table "votes", force: :cascade do |t|
    t.string "spotify_id"
    t.integer "track_id"
    t.integer "user_id"
    t.integer "vote"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["track_id"], name: "index_votes_on_track_id"
    t.index ["user_id"], name: "index_votes_on_user_id"
  end

  add_foreign_key "tracks", "users", column: "added_by_id"
end
