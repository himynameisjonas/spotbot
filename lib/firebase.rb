require 'firebase'

class Spotbot::Firebase
  attr_reader :uri

  def initialize(uri = nil)
    @uri = uri
  end

  def post
    return unless ENV['FIREBASE_URI']
    EM.defer do
      firebase.set('current_track', data)
    end
  end

  private

  def data
    Spotbot::Track.new(uri).as_json if uri
  end

  def firebase
    Firebase::Client.new(ENV['FIREBASE_URI'])
  end
end
