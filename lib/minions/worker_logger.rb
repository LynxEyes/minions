module Minions
  module WorkerLogger

    def logname= name
      FileUtils.mkdir_p File.dirname(name)
      @logname = name
    end

    def logname
      @logname ||= begin
        FileUtils.mkdir_p "./log"
        "./log/#{self.class.name.underscore}.log"
      end
    end

    def logger
      @logger ||= Logger.new(logname).tap do |l|
        l.formatter       = Logger::Formatter.new
        l.datetime_format = "%Y-%m-%d %H:%M:%S"
        l.level = ("development" == $APP_CONFIG[:env] ? Logger::DEBUG : Logger::INFO)
      end
    end

    def log message, level = :info
      logger.send(level, message)
    end

  end # module WorkerLogger
end # module Minions
