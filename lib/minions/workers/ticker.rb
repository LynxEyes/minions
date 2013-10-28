# -----------------------------------------------------------------------------
module Minions
  module Workers
    # -----------------------------------------------------------------------------
    # Ticker Worker
    # TODO: describe this...
    class Ticker

      # =============================================================================
      class << self
        def minions
          @minions ||= Minions.minions.reduce([]) do |acc, (_, minion)|
            acc += minion.task_schedules.map do |task, cron|
              [minion, task, CronTrigger.new(cron)]
            end
          end
        end # def minions

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
          self.class.minions.each do |minion, task, cron|
            schedule_task minion, task, cron
          end

          trap(:INT){}
          trap(:TERM) do
            EventMachine.stop
            finalize
            exit 0
          end
        end # EventMachine
      end

      # =============================================================================
      def schedule_task minion, task, cron
        EventMachine.add_timer_ms cron.next_trigger_ms do
          redis.publish minion.channel, MultiJson.dump({:task => task})
          schedule_task minion, task, cron
        end
      end

    end # class TickerWorker
  end # module Workers
end # module Minions
