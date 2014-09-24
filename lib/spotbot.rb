require "bundler/setup"
require 'pry'
require "logger"
require "json"
require "plaything"
require "dotenv"
require 'redis-namespace'
require "singleton"
require 'rspotify'


Dotenv.load

Thread.abort_on_exception = true

class Spotbot
  $redis = Redis::Namespace.new :spotbot
end

require_relative 'runner'
require_relative "player"
require_relative "queue"
require_relative "web"
require_relative "spotify_support"
require_relative "frame_reader"
require_relative "track"
require_relative "playlist"
require_relative "firebase"

class Plaything
  module OpenAL
    class Source
      def volume(float)
        OpenAL.listenerf :gain, [[float, 0].max, 1].min
      end
    end
  end
end

Spotbot::Runner.run
