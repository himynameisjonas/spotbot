class Spotbot::Track
  attr_reader :uri

  def initialize(uri)
    @uri = uri
  end

  def as_json
    {
      title: track.name,
      artists: track.artists.map(&:name),
      duration: track.duration_ms,
      image: image,
      uri: uri,
    }
  end

  private

  def image
    return unless track.album && track.album.images && track.album.images.first
    track.album.images.first["url"]
  end

  def track
    @track ||= RSpotify::Track.find uri_id
  end

  def uri_id
    uri.gsub("spotify:track:", "")
  end
end
