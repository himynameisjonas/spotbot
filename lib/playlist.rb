class Spotbot::Playlist
  include Singleton

  URI_KEY = "playlist:uri"
  TRACKS_KEY = "playlist:tracks"
  SHUFFLE_KEY = "playlist:shuffle"

  attr_reader :uri, :queue

  def initialize
    reset_state
    Spotbot::Firebase.playlist(as_json)
  end

  def from_uri(uri)
    return false unless valid_uri?(uri)
    reset_state
    @uri = uri
    self.shuffle = false
    redis.set URI_KEY, uri
    fetch_tracks
    populate_queue
    Spotbot::Firebase.playlist(as_json)
    self
  end

  def next
    populate_queue if queue.size == 0
    track = queue.pop
    Spotbot::Firebase.playlist(as_json)
    track
  end

  def tracks
    redis.lrange(TRACKS_KEY, 0, -1).map do |uri|
      Spotbot::Track.new uri
    end
  end

  def uri
    @uri ||= redis.get URI_KEY
  end

  def name
    if album?
      "#{album.artists.map(&:name).join(", ")}  – #{album.name}"
    else
      Spotify.playlist_name playlist
    end
  end

  def shuffle?
    redis.get(SHUFFLE_KEY) == "true"
  end

  def shuffle=(state)
    @queue = [] if shuffle? != state
    redis.set SHUFFLE_KEY, state
    Spotbot::Firebase.playlist(as_json)
  end

  def album?
    uri.match(/:album:/)
  end

  private

  def as_json
    return {} unless uri
    {
      name: name,
      uri: uri,
      shuffle: shuffle?,
      tracks: tracks.map(&:as_json),
    }
  end

  def valid_uri?(uri)
    !!uri.match(/spotify:(album:|(user:\S*:playlist:))\S+/)
  end

  def populate_queue
    return unless uri
    fetch_tracks if redis.llen(TRACKS_KEY) == 0
    @queue = redis.lrange(TRACKS_KEY, 0, -1).reverse
    @queue.shuffle! if shuffle?
  end

  def fetch_tracks
    if album?
      redis.rpush TRACKS_KEY, album.tracks.map(&:uri)
    else
      redis.rpush TRACKS_KEY, playlist_tracks
    end
  end

  def playlist
    playlist = Spotify.playlist_create support.session, link
    support.poll { Spotify.playlist_is_loaded(playlist) }
    playlist
  end

  def playlist_tracks
    tracks = []
    while track = Spotify.playlist_track(playlist, tracks.size) do
      link = Spotify.link_create_from_track track, 0
      tracks << Spotify.link_as_string(link)
    end
    tracks
  end

  def album
    @album ||= RSpotify::Album.find(uri_id)
  end

  def uri_id
    uri.gsub("spotify:album:", "")
  end

  def reset_state
    redis.del TRACKS_KEY
    @queue = []
    @album = nil
  end

  def link
    Spotify.link_create_from_string(uri)
  end

  def support
    Spotbot::SpotifySupport.instance
  end

  def redis
    $redis
  end
end
