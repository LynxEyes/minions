module Minions
  module WorkerLogger

    # -----------------------------------------------------------------------------
    def log_to name_or_stream
      # when changing the log_name, close and set the current logger to nil
      # in order for the next call to #logger yield a NEW logger!
      @logger && @logger.close && @logger = nil

      if name_or_stream.is_a? IO
        @log_name = name_or_stream
      else
        basename = File.basename name_or_stream
        extname  = File.extname basename
        dirname  = File.dirname name_or_stream

        extname  = extname.empty? ? ".log" : ""
        dirname  = "#{File.expand_path "."}/log" if dirname == "."

        FileUtils.mkdir_p dirname
        @log_name = "#{dirname}/#{basename}#{extname}"
      end
    end

    # -----------------------------------------------------------------------------
    def log_name
      @log_name ||= begin
        name = self.class.name.demodulize.underscore
        if Minions::Minion == self.class.superclass
          log_to "./log/#{name}.log"
        else
          log_to(Minions[:daemon] ? "minions_#{name}.log" : $stdout)
        end
      end
    end

    # -----------------------------------------------------------------------------
    def logger
      @logger ||= Logger.new(log_name).tap do |l|
        l.formatter = if Minions::Minion == self.class.superclass
                        Proc.new do |severity, timestamp, progname, msg|
                          "#{severity.chars.first} [#{timestamp} ##{progname || Process.pid}]: #{msg}\n"
                        end
                      else
                        Proc.new do |severity, timestamp, progname, msg|
                          "#{severity.chars.first} [#{timestamp}]: #{msg}\n"
                        end
                    end
        l.level = ("development" == Minions[:env] ? Logger::DEBUG : Logger::INFO)
      end
    end

    # -----------------------------------------------------------------------------
    def log message, level = :info
      logger.send(level, message)
    end

    # -----------------------------------------------------------------------------
    def log_exception message, exception, level = :info
      log(<<-EOS.strip_heredoc, level)
        #{message}
          #{exception.message}
          #{exception.backtrace * "\n            "}
      EOS
    end

  end # module WorkerLogger
end # module Minions
