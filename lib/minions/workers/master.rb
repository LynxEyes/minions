# -----------------------------------------------------------------------------
module Minions
  module Workers
    # -----------------------------------------------------------------------------
    # Master Worker -
    # TODO: describe this..
    class Master
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
        @callbacks = minion.master

        context.instance_exec(&minion.initializer) if minion.initializer
      end

      # -----------------------------------------------------------------------------
      def finalize
        context.instance_exec(&minion.finalizer) if minion.finalizer
        channel_listener.quit
        queue_writer.quit
      end

      # -----------------------------------------------------------------------------
      def run
        trap(:INT){}
        trap(:TERM) do
          channel_listener.unsubscribe if channel_listener.subscribed?
        end

        channel_listener.subscribe minion.channel do |on|
          on.message do |_, message|
            json_message = MultiJson.load(message, :symbolize_keys => true)
            task = json_message[:task].to_sym
            args = json_message[:args] || []
            context.instance_exec(args, &callbacks[task]) if callbacks[task]
          end
        end

        finalize
        exit 0
      end

      # -----------------------------------------------------------------------------
      def enqueue task, *args
        queue_writer.lpush minion.queue, MultiJson.dump({
          :task => task,
          :args => args
        })
      end

      # =============================================================================
      private

        # -----------------------------------------------------------------------------
        def channel_listener
          @channel_listener ||= Redis.new(:url => Minions.redis_url)
        end

        def queue_writer
          @queue_writer ||= Redis.new(:url => Minions.redis_url)
        end

        # -----------------------------------------------------------------------------
        # def push_job args
        #   raise "TODO"
        #   # redis.lpush minion.queue, args
        # end

    end
  end # module Workers
end # module Minions
