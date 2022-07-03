FactoryBot.define do
  factory :user do
    spotify_id { Faker::Number.number(digits: 16) }
  end

  factory :playlist do
    user
    name { Faker::Name.name }
    share_setting { :visible }
  end

  factory :track do
    playlist
    user
    playlist_id { Faker::Number.number(digits: 16) }
    spotify_id { Faker::Number.number(digits: 16) }
  end

  factory :vote do
    user
    track
  end
end
