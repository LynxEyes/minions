module Minions
  module WorkerLogger

    def logname name = nil
      (name && @logname = name) || @logname || self.class.name.underscore
    end

    def logger
      @logger ||= Logger.new("#{logname}.log").tap do |l|
        l.formatter       = Logger::Formatter.new
        l.datetime_format = "%Y-%m-%d %H:%M:%S"
        l.level = if defined? APP_ENV
                    "development" == APP_ENV ? Logger::DEBUG : Logger::INFO
                  else
                    Logger::DEBUG
                  end
      end
    end

    def log message, level = :info
      logger.send(level, message)
    end

  end # module WorkerLogger
end # module Minions
