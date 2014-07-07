require "bundler/setup"
# require 'eventmachine'
require_relative "player"
require_relative "track_queue"

class Spotbot
  def self.run
    # EM.run do
      queue = TrackQueue.new
      player = Player.new(queue)
      player.run
      # Thin::Server.start WebApp.new(self), '0.0.0.0', 3000
    # end
  end
end

Spotbot.run
