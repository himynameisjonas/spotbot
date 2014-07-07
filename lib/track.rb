class Spotbot::Track
  attr_reader :track_link

  def self.from_uri(uri)
    new Spotify.link_create_from_string(uri)
  end

  def initialize(track_link)
    @track_link = track_link
  end

  def title
    @title ||= loaded do
      Spotify.track_name(track)
    end
  end

  def artists
    @artists ||= loaded do
      Spotify.track_num_artists(track).times.map do |index|
        Spotify.artist_name Spotify.track_artist(track, index)
      end
    end
  end

  def duration
    @duration ||= loaded do
      Spotify.track_duration(track)
    end
  end

  def as_json(*)
    {
      title: title,
      artists: artists,
      duration: duration,
    }
  end

  private

  def is_loaded?
    support.poll { Spotify.track_is_loaded(track) }
  end

  def track
    @track ||= Spotify.link_as_track(track_link)
  end

  def support
    Spotbot::SpotifySupport.instance
  end

  def loaded(&block)
    is_loaded?
    yield
  end
end
