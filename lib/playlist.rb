class Spotbot::Playlist
  include Singleton

  URI_KEY = "playlist:uri"
  TRACKS_KEY = "playlist:tracks"
  SHUFFLE_KEY = "playlist:shuffle"

  attr_reader :uri, :queue

  def initialize
    reset_state
  end

  def from_uri(uri)
    reset_state
    @uri = uri
    redis.set URI_KEY, uri
    fetch_tracks
    populate_queue
    self
  end

  def next
    populate_queue if queue.size == 0
    queue.pop
  end

  def tracks
    redis.lrange(TRACKS_KEY, 0, -1).map do |uri|
      Spotbot::Track.from_uri uri
    end
  end

  def uri
    @uri ||= redis.get URI_KEY
  end

  def name
    Spotify.playlist_name playlist
  end

  def shuffle
    redis.get(SHUFFLE_KEY) == "true"
  end

  def shuffle=(state)
    @queue = [] if shuffle != state
    redis.set SHUFFLE_KEY, state
  end

  private

  def populate_queue
    fetch_tracks if redis.llen(TRACKS_KEY) == 0
    @queue = redis.lrange(TRACKS_KEY, 0, -1).reverse
    @queue.shuffle! if shuffle
  end

  def fetch_tracks
    index = 0
    while track = Spotify.playlist_track(playlist, index) do
      link = Spotify.link_create_from_track track, 0
      redis.rpush TRACKS_KEY, Spotify.link_as_string(link)
      index += 1
    end
  end

  def playlist
    playlist = Spotify.playlist_create support.session, link
    support.poll { Spotify.playlist_is_loaded(playlist) }
    playlist
  end

  def reset_state
    redis.del TRACKS_KEY
    @queue = []
    self.shuffle = false
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
