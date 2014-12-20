require 'eventmachine'
require 'thin'

class Spotbot::Runner

  # We use a logger to print some information on when things are happening.
  $stderr.sync = true
  $logger = Logger.new($stderr)
  $logger.level = Logger::INFO
  $logger.formatter = proc do |severity, datetime, progname, msg|
    progname = if progname
      " (#{progname}) "
    else
      " "
    end
    "\n[#{severity} @ #{datetime.strftime("%H:%M:%S")}]#{progname}#{msg}"
  end

  def self.run
    player = Spotbot::Player.new($logger)

    player_thread = Thread.new do
      EM.run do
        player.run
      end
    end

    server_thread = Thread.new do
      Thin::Server.start(Spotbot::Web.new(player), '0.0.0.0', ENV['SERVER_PORT'], signals: false)
    end

    Signal.trap("INT") { EM.stop }
    Signal.trap("TERM") { EM.stop }

    player_thread.join
    server_thread.join
  end
end
