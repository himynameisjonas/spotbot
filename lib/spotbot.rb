require "bundler/setup"

class Spotbot
end

require_relative 'runner'

Spotbot::Runner.run
