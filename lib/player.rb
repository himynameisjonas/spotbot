#!/usr/bin/env ruby
# encoding: utf-8

class Spotbot::Player
  attr_accessor :current_track
  attr_reader :queue, :plaything, :session, :support, :logger

  def initialize(queue, logger)
    @queue = queue
    @logger = logger
    @plaything = Plaything.new
  end

  def run
    @support = Spotbot::SpotifySupport.instance
    Spotbot::SpotifySupport::DEFAULT_CONFIG[:callbacks] = Spotify::SessionCallbacks.new(session_callbacks)

    @session = support.initialize_spotify!

    play_next

    EM.defer do
      support.poll { } # keep the player running
    end
  end

  def play
    play_next unless current_track
    Spotify.try(:session_player_play, session, true)
  end

  def pause
    Spotify.try(:session_player_play, session, false)
  end

  def play_next
    if track = queue.next
      play_track(track)
      track
    end
  end

  private

  def play_track(uri)
    logger.info("play_track") { uri }

    link = Spotify.link_create_from_string(uri)
    track = Spotify.link_as_track(link)
    support.poll { Spotify.track_is_loaded(track) }
    current_track = track

    # Pause before we load a new track. Fixes a quirk in libspotify.
    Spotify.try(:session_player_play, session, false)
    Spotify.try(:session_player_load, session, track)
    Spotify.try(:session_player_play, session, true)
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
        current_track = nil
        logger.debug("session (player)") { "end of track" }
        if track = queue.next
          logger.info("session (player) track") { track }
          play_track(track)
        else
          plaything.stop
        end
      end,
    }
  end
end
