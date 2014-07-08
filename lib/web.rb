require 'sinatra'
require "sinatra/json"
require "sinatra/namespace"

class Spotbot::Web < Sinatra::Base
  helpers Sinatra::JSON
  register Sinatra::Namespace

  attr_reader :player, :queue

  def initialize(player, queue)
    @queue = queue
    @player = player
    super()
  end

  before do
    content_type 'application/json'
  end

  namespace '/queue' do
    get '/tracks' do
      json queue.all.map(&:as_json)
    end

    post '/tracks' do
      track = queue.add(params[:uri])
      json track.as_json
    end

    delete '' do
      queue.clear
      json []
    end
  end

  namespace '/player' do
    put '/stop' do
      player.pause
      json :ok
    end

    put '/start' do
      player.play
      if track = player.current_track
        json track_as_json(track)
      else
        json :ok
      end
    end

    put '/next' do
      if track = player.play_next
        json track_as_json(track)
      else
        json :ok
      end
    end

    get '/track' do
      if track = player.current_track
        json track_as_json(track)
      else
        json :ok
      end
    end
  end

  get "/favicon.ico" do
  end

  private

  def track_as_json(uri)
    Spotbot::Track.from_uri(uri).as_json
  end
end
