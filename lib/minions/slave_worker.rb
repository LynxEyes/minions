module Minions
  # -----------------------------------------------------------------------------
  # Slave Worker
  # TODO - describe this...
  class SlaveWorker
    include WorkerLogger

    # =============================================================================
    class << self
      def run minion_class
        self.new(minion_class).run
      end
    end
    # =============================================================================
    attr_reader :minion, :context, :callbacks
    # -----------------------------------------------------------------------------
    def initialize minion_klazz
      @minion    = minion_klazz
      @context   = minion.new(self)
      @callbacks = minion.slave

      context.instance_exec(&minion.initialize) if minion.initialize
    end

    # -----------------------------------------------------------------------------
    def finalize
      # log "finalizing.."
      context.instance_exec(&minion.finalize) if minion.finalize
      redis.quit
    end

    # -----------------------------------------------------------------------------
    def run
      stop_and_exit = false
      trap :TERM do
        stop_and_exit = true
      end

      loop do
        if job = get_job
          task, args = job[:task].to_sym, job[:args]
          context.instance_exec *args, &callbacks[task]
        end
        if stop_and_exit
          finalize
          exit 0
        end
      end
    end

    private
      # -----------------------------------------------------------------------------
      def redis
        @redis ||= Redis.new(:url => Minions.redis_url)
      end

      # -----------------------------------------------------------------------------
      def get_job
        if job = redis.brpop(minion.queue, 5)
          _, job = job
          MultiJson.load(job, :symbolize_keys => true)
        end
      end

  end
end # module Minions
