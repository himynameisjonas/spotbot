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
    queue = Spotbot::Queue.new
    EM.schedule do
      trap("INT") { EM.stop }
    end

    EM.run do
      Spotbot::Player.new(queue, $logger).run
      Thin::Server.start Spotbot::Web.new(queue), '0.0.0.0', 3000
    end
  end
end
