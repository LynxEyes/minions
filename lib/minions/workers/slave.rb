# -----------------------------------------------------------------------------
module Minions
  module Workers
    # -----------------------------------------------------------------------------
    # Slave Worker
    # TODO - describe this...
    class Slave
      include WorkerLogger

      # =============================================================================
      class << self
        def run minion_name
          minion_class = Minions.load_worker minion_name.to_sym
          self.new(minion_class).run
        end
      end
      # =============================================================================
      # -----------------------------------------------------------------------------
      attr_reader :minion, :context, :callbacks
      # -----------------------------------------------------------------------------
      def initialize minion_class
        @minion    = minion_class
        @context   = minion.new(self)
        @callbacks = minion.slave

        context.instance_exec(&minion.initializer) if minion.initializer
      end

      # -----------------------------------------------------------------------------
      def finalize
        # log "finalizing.."
        context.instance_exec(&minion.finalizer) if minion.finalizer
        redis.quit
      end

      # -----------------------------------------------------------------------------
      def run
        stop_and_exit = false
        trap(:INT){}
        trap :TERM do
          stop_and_exit = true
        end

        loop do
          if job = get_job
            task, args = job[:task].to_sym, (job[:args] || [])
            context.instance_exec args, &callbacks[task]
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
      # private end..

    end
  end # module Workers
end # module Minions
