require 'firebase'

class Spotbot::Firebase

  def current_track=(uri)
    return unless ENV['FIREBASE_URI']
    EM.defer do
      firebase.set('current_track', track_from_uri(uri).as_json)
    end
  end

  private

  def track_from_uri(uri)
    Spotbot::Track.from_uri(uri)
  end

  def firebase
    Firebase::Client.new(ENV['FIREBASE_URI'])
  end
end
