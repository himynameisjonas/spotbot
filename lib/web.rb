require 'sinatra'
require "sinatra/json"
require "sinatra/namespace"

class Spotbot::Web < Sinatra::Base
  helpers Sinatra::JSON
  register Sinatra::Namespace

  attr_reader :queue

  def initialize(queue)
    @queue = queue
    super
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

  get "/favicon.ico" do
  end
end
