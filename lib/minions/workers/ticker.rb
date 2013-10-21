# -----------------------------------------------------------------------------
module Minions
  module Workers
    # -----------------------------------------------------------------------------
    # Ticker Worker
    # TODO: describe this...
    class Ticker

      # =============================================================================
      class << self
        def workers
          @workers ||= Minions.workers.reduce([]) do |acc, (worker, worker_conf)|
            acc += worker_conf[:tasks].map do |task, cron|
              [worker, task, CronTrigger.new(cron)]
            end
          end
        end # def workers

        def run; self.new.run; end
      end

      attr_reader :redis
      # =============================================================================
      def initialize
        @redis = Redis.new :url => Minions.redis_url
      end

      def finalize
        redis.quit
      end

      # =============================================================================
      def run
        EventMachine.run do
          self.class.workers.each do |worker, task, cron|
            schedule_task worker, task, cron
          end

          trap(:TERM) do
            EventMachine.stop
            finalize
            exit 0
          end
        end # EventMachine
      end

      # =============================================================================
      def schedule_task worker, task, cron
        EventMachine.add_timer_ms cron.next_trigger_ms do
          redis.publish "##{worker}", MultiJson.dump({:task => task})
          schedule_task worker, task, cron
        end
      end

    end # class TickerWorker
  end # module Workers
end # module Minions
