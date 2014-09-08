#!/usr/bin/env ruby
# encoding: utf-8

class Spotbot::Player
  attr_reader :queue, :playlist, :plaything, :support, :logger, :current_track, :changing_track

  def initialize(logger)
    @queue = Spotbot::Queue.instance
    @playlist = Spotbot::Playlist.instance
    @logger = logger
    @plaything = Plaything.new
    @changing_track = false
  end

  def run
    @support = Spotbot::SpotifySupport.instance
    Spotbot::SpotifySupport::DEFAULT_CONFIG[:callbacks] = Spotify::SessionCallbacks.new(session_callbacks)

    support.initialize_spotify!

    play_next

    EM.defer do
      support.poll { } # keep the player running
    end
  end

  def play(uri = nil)
    play_track(uri) if uri
    play_next unless current_track
    Spotify.try(:session_player_play, support.session, true)
  end

  def pause
    Spotify.try(:session_player_play, support.session, false)
  end

  def play_next
    if track = next_track
      play_track(track)
      track
    end
  end

  private

  def next_track
    queue.next || playlist.next
  end

  def play_track(uri)
    @changing_track = true
    logger.info("play_track") { uri }

    link = Spotify.link_create_from_string(uri)
    track = Spotify.link_as_track(link)
    support.poll { Spotify.track_is_loaded(track) }
    self.current_track = uri

    # Pause before we load a new track. Fixes a quirk in libspotify.
    Spotify.try(:session_player_play, support.session, false)
    Spotify.try(:session_player_load, support.session, track)
    Spotify.try(:session_player_play, support.session, true)
    @changing_track = false
  end

  def current_track=(uri)
    @current_track = uri
    Spotbot::Firebase.current_track(uri) if uri
  end

  def session_callbacks
    @session_callbacks ||= {
      log_message: proc do |session, message|
        logger.info("session (log message)") { message }
      end,

      logged_in: proc do |session, error|
        logger.debug("session (logged in)") { Spotify::Error.explain(error) }
      end,

      logged_out: proc do |session|
        logger.debug("session (logged out)") { "logged out!" }
      end,

      streaming_error: proc do |session, error|
        logger.error("session (player)") { "streaming error %s" % Spotify::Error.explain(error) }
      end,

      start_playback: proc do |session|
        logger.debug("session (player)") { "start playback" }
        plaything.play
      end,

      stop_playback: proc do |session|
        logger.debug("session (player)") { "stop playback" }
        plaything.stop
      end,

      get_audio_buffer_stats: proc do |session, stats|
        stats[:samples] = plaything.queue_size
        stats[:stutter] = plaything.drops
        logger.debug("session (player)") { "queue size [#{stats[:samples]}, #{stats[:stutter]}]" }
      end,

      music_delivery: proc do |session, format, frames, num_frames|
        if num_frames == 0
          logger.debug("session (player)") { "music delivery audio discontuity" }
          plaything.stop
          0
        else
          frames = FrameReader.new(format[:channels], format[:sample_type], num_frames, frames)
          consumed_frames = plaything.stream(frames, format.to_h)
          logger.debug("session (player)") { "music delivery #{consumed_frames} of #{num_frames}" }
          consumed_frames
        end
      end,

      end_of_track: proc do |session|
        unless changing_track
          logger.debug("session (player)") { "end of track" }
          self.current_track = nil
          play_next
        end
      end,
    }
  end
end
