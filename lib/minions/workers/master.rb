# -----------------------------------------------------------------------------
module Minions
  module Workers
    # -----------------------------------------------------------------------------
    # Master Worker -
    # TODO: describe this..
    class Master
      include WorkerLogger

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

        context.instance_exec(&minion.initialize) if minion.initialize
      end

      # -----------------------------------------------------------------------------
      def finalize
        context.instance_exec(&minion.finalize) if minion.finalize
        channel_listener.quit
        queue_writer.quit
      end

      # -----------------------------------------------------------------------------
      def run
        pids = minion.number_of_slaves.times.map do |i|
          fork || Slave.run(minion)
        end

        PID.write_slaves pids

        trap(:TERM) do
          channel_listener.unsubscribe if channel_listener.subscribed?

          pids.each do |pid|
            puts "Stopping #{pid}"
            Process.kill :TERM, pid
          end
          puts "waiting for all children to die"
          Process.waitall
          PID.delete_slaves
        end

        # puts "Master pid: #{Process.pid}; slave pids: #{pids.join ', '}"
        channel_listener.subscribe minion.channel do |on|
          on.message do |_, message|
            task = MultiJson.load(message, :symbolize_keys => true)[:task].to_sym
            context.instance_exec(&callbacks[task]) if callbacks[task]
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
