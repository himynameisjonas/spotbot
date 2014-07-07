require 'sinatra'

class Spotbot::Web < Sinatra::Base
  attr_reader :queue
  def initialize(queue)
    @queue = queue
    super
  end

  get '/queue' do
    queue.all.to_json
  end


  get '/add' do
    queue.add "spotify:track:4pT1Ynb6upuZWqDowvW9sB"
    queue.add "spotify:track:65ntj1o59qVq939R5PzrMX"
  end

  get "/favicon.ico" do
  end
end
