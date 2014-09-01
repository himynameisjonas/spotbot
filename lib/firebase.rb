require 'firebase'

class Spotbot::Firebase
  attr_reader :key, :data

  def self.current_track(uri = nil)
    data = Spotbot::Track.new(uri).as_json if uri
    new(:current_track, data).post
  end

  def self.queue(queue)
    new(:queue, queue.map(&:as_json)).post
  end

  def self.playlist(json)
    new(:playlist, json).post
  end

  def initialize(key, data)
    @key = key
    @data = data
  end

  def post
    return unless ENV['FIREBASE_URI']
    EM.defer do
      firebase.set(key, data)
    end
  end

  private

  def firebase
    Firebase::Client.new(ENV['FIREBASE_URI'])
  end
end
