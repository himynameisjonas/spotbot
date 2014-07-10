require 'firebase'

class Spotbot::Firebase

  def initialize
    at_exit do
      firebase.set('current_track', nil)
    end
  end

  def current_track=(uri)
    return unless ENV['FIREBASE_URI']
    EM.defer do
      if uri
        firebase.set('current_track', track_from_uri(uri).as_json)
      else
        firebase.set('current_track', nil)
      end
    end
  end

  private

  def track_from_uri(uri)
    Spotbot::Track.new(uri)
  end

  def firebase
    Firebase::Client.new(ENV['FIREBASE_URI'])
  end
end
