require 'redis-namespace'

class Spotbot::Queue
  attr_reader :redis
  KEY_NAME = :track_queue

  def initialize
    @redis = Redis::Namespace.new :spotbot
  end

  def next
    redis.lpop KEY_NAME
  end

  def add(track)
    redis.rpush KEY_NAME, track
    Spotbot::Track.from_uri(track)
  end

  def all
    redis.lrange(KEY_NAME, 0, -1).map do |uri|
      Spotbot::Track.from_uri uri
    end
  end

  def clear
    redis.del KEY_NAME
  end
end
