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
      json :ok
    end

    put '/next' do
      if track = player.play_next
        json Spotbot::Track.from_uri(track).as_json
      else
        json :ok
      end
    end
  end

  get "/favicon.ico" do
  end
end
