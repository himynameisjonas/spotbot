#!/usr/bin/env ruby
# encoding: utf-8

require_relative "spotify_support"
require_relative "frame_reader"

require "json"
require "plaything"

class Player
  attr_reader :queue, :plaything, :session

  def session_callbacks
    @session_callbacks ||= {
      log_message: proc do |session, message|
        Support.logger.info("session (log message)") { message }
      end,

      logged_in: proc do |session, error|
        Support.logger.debug("session (logged in)") { Spotify::Error.explain(error) }
      end,

      logged_out: proc do |session|
        Support.logger.debug("session (logged out)") { "logged out!" }
      end,

      streaming_error: proc do |session, error|
        Support.logger.error("session (player)") { "streaming error %s" % Spotify::Error.explain(error) }
      end,

      start_playback: proc do |session|
        Support.logger.debug("session (player)") { "start playback" }
        plaything.play
      end,

      stop_playback: proc do |session|
        Support.logger.debug("session (player)") { "stop playback" }
        plaything.stop
      end,

      get_audio_buffer_stats: proc do |session, stats|
        stats[:samples] = plaything.queue_size
        stats[:stutter] = plaything.drops
        Support.logger.debug("session (player)") { "queue size [#{stats[:samples]}, #{stats[:stutter]}]" }
      end,

      music_delivery: proc do |session, format, frames, num_frames|
        if num_frames == 0
          Support.logger.debug("session (player)") { "music delivery audio discontuity" }
          plaything.stop
          0
        else
          frames = FrameReader.new(format[:channels], format[:sample_type], num_frames, frames)
          consumed_frames = plaything.stream(frames, format.to_h)
          Support.logger.debug("session (player)") { "music delivery #{consumed_frames} of #{num_frames}" }
          consumed_frames
        end
      end,

      end_of_track: proc do |session|
        $end_of_track = true
        Support.logger.debug("session (player)") { "end of track" }
        Support.logger.info("session (player)") { "track queue" }
        if track = queue.next
          Support.logger.info("session (player) track") { track }
          play_track(track)
        else
          plaything.stop
        end
      end,
    }
  end

  def initialize(queue)
    @queue = queue
    @plaything = Plaything.new
  end

  def run
    Support::DEFAULT_CONFIG[:callbacks] = Spotify::SessionCallbacks.new(session_callbacks)

    @session = Support.initialize_spotify!
    queue.add "spotify:track:4pT1Ynb6upuZWqDowvW9sB"
    queue.add "spotify:track:65ntj1o59qVq939R5PzrMX"

    play_track(queue.next)

    Support.logger.info "Playing track until end. Use ^C to exit."
    Support.poll(session) { false }
  end

  def play_track(uri)
    Support.logger.info("play_track") { uri }

    link = Spotify.link_create_from_string(uri)
    track = Spotify.link_as_track(link)
    Support.poll(session) { Spotify.track_is_loaded(track) }

    # Pause before we load a new track. Fixes a quirk in libspotify.
    Spotify.try(:session_player_play, session, false)
    Spotify.try(:session_player_load, session, track)
    Spotify.try(:session_player_play, session, true)
  end
end
