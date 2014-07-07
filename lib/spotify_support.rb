require "spotify"
require "logger"
require "pry"
require "io/console"

# Kill main thread if any other thread dies.
Thread.abort_on_exception = true


module Support
  module_function

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

  class << self
    attr_accessor :silenced
  end

  # libspotify supports callbacks, but they are not useful for waiting on
  # operations (how they fire can be strange at times, and sometimes they
  # might not fire at all). As a result, polling is the way to go.
  def poll(session, idle_time = 0.05)
    until yield
      print "." unless silenced
      process_events(session)
      sleep(idle_time)
    end
  end

  # Process libspotify events once.
  def process_events(session)
    Spotify.session_process_events(session)
  end

  def initialize_spotify!(config = DEFAULT_CONFIG)
    error, session = Spotify.session_create(config)
    raise Spotify::Error.new(error) if error

    if username = Spotify.session_remembered_user(session)
      logger.info "Using remembered login for: #{username}."
      Spotify.try(:session_relogin, session)
    else
      username = prompt("Spotify username, or Facebook e-mail")
      password = $stdin.noecho { prompt("Spotify password, or Facebook password") }

      logger.info "Attempting login with #{username}."
      Spotify.try(:session_login, session, username, password, true, nil)
    end

    logger.info "Log in requested. Waiting forever until logged in."
    Support.poll(session) { Spotify.session_connectionstate(session) == :logged_in }

    at_exit do
      logger.info "Logging out."
      Spotify.session_logout(session)
      Support.poll(session) { Spotify.session_connectionstate(session) != :logged_in }
    end

    session
  end
end
