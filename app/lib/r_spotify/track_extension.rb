# frozen_string_literal: true

module RSpotify
  module TrackExtension
    def find(ids, market: nil)
      if ids.is_a? Array
        ids_in_cache, ids_to_cache = ids.partition do |id|
          Rails.cache.exist?("rspotify:track:#{id}")
        end

        tracks_to_cache = []
        if ids_to_cache.any?
          ids.each_slice(50) do |slice_ids|
            tracks_to_cache.concat(super(slice_ids, market: market))
          end
          tracks_to_write_multi = tracks_to_cache.index_by do |track|
            "rspotify:track:#{track.id}"
          end
          Rails.cache.write_multi(tracks_to_write_multi, expires_in: 1.day)
        end

        keys_in_cache = ids_in_cache.map { |id| "rspotify:track:#{id}" }
        tracks_cached = Rails.cache.read_multi(*keys_in_cache)
        tracks_to_cache.concat(tracks_cached.values)
      else
        Rails.cache.fetch("rspotify:track:#{ids}", expires_in: 1.day) do
          super(ids, market: market)
        end
      end
    end
  end
end

RSpotify::Track.singleton_class.prepend RSpotify::TrackExtension
