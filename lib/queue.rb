class Spotbot::Queue
  include Singleton

  attr_reader :redis
  KEY_NAME = :track_queue

  def next
    track = redis.lpop KEY_NAME
    update_firebase
    track
  end

  def add(track)
    redis.rpush KEY_NAME, track
    update_firebase
    Spotbot::Track.new(track)
  end

  def all
    redis.lrange(KEY_NAME, 0, -1).map do |uri|
      Spotbot::Track.new uri
    end
  end

  def clear
    redis.del KEY_NAME
    update_firebase
  end

  private

  def update_firebase
    Spotbot::Firebase.queue(all)
  end

  def redis
    $redis
  end
end
