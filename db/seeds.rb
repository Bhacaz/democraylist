# frozen_string_literal: true
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

user = User.first

# Playlist.create! user_id: user.id, name: 'My first playlist', description: 'This is my first playlist', share_setting: :visible, song_size: 25
# Playlist.create! user_id: user.id, name: 'My second playlist', description: 'This is my second playlist', share_setting: :visible, song_size: 25
# Playlist.create! user_id: user.id, name: 'My third playlist', description: 'This is my third playlist', share_setting: :visible, song_size: 25
# Playlist.create! user_id: user.id, name: 'My fourth playlist', description: 'This is my fourth playlist', share_setting: :visible, song_size: 25
# Playlist.create! user_id: user.id, name: 'My fifth playlist', description: 'This is my fifth playlist', share_setting: :visible, song_size: 25
# Playlist.create! user_id: user.id, name: 'My sixth playlist', description: 'This is my sixth playlist', share_setting: :visible, song_size: 25
# Playlist.create! user_id: user.id, name: 'My seventh playlist', description: 'This is my seventh playlist', share_setting: :visible, song_size: 25
# Playlist.create! user_id: user.id, name: 'My eighth playlist', description: 'This is my eighth playlist', share_setting: :visible, song_size: 25
# Playlist.create! user_id: user.id, name: 'My ninth playlist', description: 'This is my ninth playlist', share_setting: :visible, song_size: 25
# Playlist.create! user_id: user.id, name: 'My tenth playlist', description: 'This is my tenth playlist', share_setting: :visible, song_size: 25
# Playlist.create! user_id: user.id, name: 'My eleventh playlist', description: 'This is my eleventh playlist', share_setting: :visible, song_size: 25

# user2 = User.create! email: 'test@example.com', name: 'Second User', spotify_id: 'test'

# user2.subscriptions.create! playlist_id: Playlist.first.id
# user2.subscriptions.create! playlist_id: Playlist.second.id
# user2.subscriptions.create! playlist_id: Playlist.third.id

Track.create! playlist: Playlist.first, spotify_id: '1', added_by: user


