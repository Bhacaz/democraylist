class TrackSerializer
  include BrightSerializer::Serializer

  attributes(*Track.attribute_names.map(&:to_sym))

  attribute :vote_count do |object|
    object.vote_score
  end

  attribute :up_vote_count do |object|
    object.votes.count { |vote| vote.up? }
  end

  attribute :down_vote_count do |object|
    object.votes.count { |vote| vote.down? }
  end

  attribute :my_vote do |object, params|
    object.votes.detect { |vote| vote.user_id == params[:auth_user_id] }&.vote
  end

  attribute :added_by do |object|
    {
      id: object.user.id,
      name: object.user.name,
      spotify_id: object.user.spotify_id
    }
  end
end
