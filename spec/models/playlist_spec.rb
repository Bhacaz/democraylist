
describe Playlist do
  describe 'validations' do
    subject {build_stubbed :playlist}
    it { is_expected.to be_valid }
  end

  describe '#real_tracks' do
    # Setup:
    # - Playlist with limit of 3 tracks
    # - Add 4 tracks
    # - Up vote all track once
    # - Down vote track index 2, once
    # - Down vote track index 3, twice
    # -  So track index 3 have more down votes than track index 2
    #      and the track index 3 is out, even track index 2 have
    #      a more recent vote (updated_at most recent)

    let(:playlist) {create :playlist, song_size: 3, user: user}
    let(:tracks) { create_list :track, 4, playlist: playlist, user: user }
    let(:user) { create :user }

    before do
      tracks.first(2).each do |track|
        create :vote, track: track, vote: :up, user: user
      end

      create :vote, track: tracks[2], vote: :down, user: user, updated_at: 1.minute.ago
      create :vote, track: tracks[2], vote: :up, updated_at: 1.minute.ago
      create :vote, track: tracks[3], vote: :up, user: user, updated_at: 3.minute.ago
      create :vote, track: tracks[3], vote: :down, updated_at: 3.minute.ago
      create :vote, track: tracks[3], vote: :down, updated_at: 3.minute.ago
    end

    it 'returns the tracks in the playlist' do
      expect(playlist.real_tracks).to match_array tracks.first(3)
    end
  end
end
