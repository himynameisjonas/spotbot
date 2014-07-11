require 'sinatra'
require "sinatra/json"
require "sinatra/namespace"

class Spotbot::Web < Sinatra::Base
  attr_reader :player, :queue, :playlist

  configure do
    helpers Sinatra::JSON
    register Sinatra::Namespace
    set :show_exceptions, false
    enable :logging
  end

  def initialize(player)
    @queue = Spotbot::Queue.instance
    @playlist = Spotbot::Playlist.instance
    @player = player
    super()
  end

  before do
    headers['Access-Control-Allow-Methods'] = 'GET, POST, PUT, DELETE, OPTIONS'
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Allow-Headers'] = 'accept, authorization, origin'
    headers['Access-Control-Allow-Credentials'] = 'true'
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
      json status: :ok
    end

    put '/start' do
      player.play
      if track = player.current_track
        json track_as_json(track)
      else
        json status: :ok
      end
    end

    put '/next' do
      if track = player.play_next
        json track_as_json(track)
      else
        json status: :ok
      end
    end

    get '/track' do
      if track = player.current_track
        json track_as_json(track)
      else
        json status: :ok
      end
    end

    post '/track' do
      player.play(params[:uri])
      json track_as_json(params[:uri])
    end
  end

  namespace '/playlist' do
    get '' do
      json playlist: playlist.name
    end

    post '' do
      if playlist.from_uri params[:uri]
        json playlist: playlist.name
      else
        json status: :invalid
      end
    end

    get '/tracks' do
      raise StandardError
      json "current playlist tracks"
    end

    get '/shuffle' do
      json shuffle: playlist.shuffle?
    end

    put '/shuffle' do
      playlist.shuffle = true
      json shuffle: playlist.shuffle?
    end

    delete '/shuffle' do
      playlist.shuffle = false
      json shuffle: playlist.shuffle?
    end
  end

  get "/favicon.ico" do
  end

  error do |err|
    puts err.inspect
  end

  options "*" do
    halt 200
  end

  private

  def track_as_json(uri)
    Spotbot::Track.new(uri).as_json
  end
end
