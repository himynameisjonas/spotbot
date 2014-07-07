require 'redis-namespace'

class TrackQueue
  attr_reader :redis
  def initialize
    @redis = Redis::Namespace.new :spotbot
  end

  def next
    redis.lpop :track_queue
  end

  def add(track)
    redis.rpush :track_queue, track
  end
end
