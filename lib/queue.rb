class Spotbot::Queue
  include Singleton

  attr_reader :redis
  KEY_NAME = :track_queue_set

  def next
    result = redis.multi do
      redis.zrange KEY_NAME, 0, 0
      redis.zremrangebyrank KEY_NAME, 0, 0
    end
    track = result.first.try(:first)
    update_firebase
    track
  end

  def add(track)
    redis.zadd KEY_NAME, score, track
    update_firebase
    Spotbot::Track.new(track)
  end

  def all
    redis.zrange(KEY_NAME, 0, -1).map do |uri|
      Spotbot::Track.new uri
    end
  end

  def clear
    redis.del KEY_NAME
    update_firebase
  end


  private

  def score
    Time.now.to_i
  end

  def update_firebase
    Spotbot::Firebase.queue(all)
  end

  def redis
    $redis
  end
end
