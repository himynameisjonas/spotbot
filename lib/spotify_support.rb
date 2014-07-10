require "spotify"
require "pry"
require "io/console"

class Spotbot::SpotifySupport
  include Singleton

  attr_reader :session

  DEFAULT_CONFIG = {
    api_version: Spotify::API_VERSION.to_i,
    application_key: File.binread("./spotify_appkey.key"),
    cache_location: ".spotify/",
    settings_location: ".spotify/",
    user_agent: "spotify for ruby",
    callbacks: Spotify::SessionCallbacks.new
  }

  def logger
    $logger
  end

  # libspotify supports callbacks, but they are not useful for waiting on
  # operations (how they fire can be strange at times, and sometimes they
  # might not fire at all). As a result, polling is the way to go.
  def poll(idle_time = 0.05)
    until yield
      process_events(session)
      sleep(idle_time)
    end
  end

  # Process libspotify events once.
  def process_events(session)
    Spotify.session_process_events(session)
  end

  def initialize_spotify!(config = DEFAULT_CONFIG)
    error, @session = Spotify.session_create(config)
    raise Spotify::Error.new(error) if error

    if username = Spotify.session_remembered_user(@session)
      logger.info "Using remembered login for: #{username}."
      Spotify.try(:session_relogin, @session)
    else
      username = ENV["SPOTIFY_USERNAME"]
      password = ENV["SPOTIFY_PASSWORD"]

      logger.info "Attempting login with #{username}."
      Spotify.try(:session_login, @session, username, password, true, nil)
    end

    logger.info "Log in requested. Waiting forever until logged in."
    poll { Spotify.session_connectionstate(@session) == :logged_in }

    if ENV['LAST_FM_USERNAME'] && ENV['LAST_FM_PASSWORD']
      logger.info "Scrobbling to Lastfm"
      Spotify.session_set_social_credentials(session, :lastfm, ENV['LAST_FM_USERNAME'], ENV['LAST_FM_PASSWORD'])
      Spotify.session_set_scrobbling(session, :lastfm, :local_enabled)
    else
      logger.info "Not scrobbling to Lastfm"
    end

    at_exit do
      logger.info "Logging out."
      Spotbot::Firebase.new.post
      Spotify.session_logout(@session)
      poll { Spotify.session_connectionstate(@session) != :logged_in }
    end
    @session
  end
end
