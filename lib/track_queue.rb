require 'redis-namespace'

class TrackQueue
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
  end

  def all
    redis.lrange KEY_NAME, 0, -1
  end
end
