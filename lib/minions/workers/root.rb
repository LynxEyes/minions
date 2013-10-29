# -----------------------------------------------------------------------------
module Minions
  module Workers
    # -----------------------------------------------------------------------------
    # Root Worker - the father of all worker processes!
    # This should work as a monitor, keeping all sub-processes behaving nicelly...
    class Root
      include WorkerLogger

      # =============================================================================
      def self.run
        self.new.run
      end
      # =============================================================================

      def initialize
        # TODO - initialize
      end

      # -----------------------------------------------------------------------------
      def finalize
        # TODO - finalize
      end

      # -----------------------------------------------------------------------------
      def run
        start_workers
        register_pids

        at_exit do
          stop_workers
          unregister_pids
        end

        Process.waitall # This is to be replaced by a process monitoring routine...

      ensure # TODO - this is only here because that waitall up there blows up on live mode
             #        when replacing it with tme monitoring routing, remove this "ensure"
        exit 0
      end

      private
        # -----------------------------------------------------------------------------
        def start_workers
          @ticker  = fork || Ticker.run
          log "Started Ticker: #{@ticker}"

          log "Starting Workers"
          @workers = Minions.minions.reduce({}) do |acc, (name, conf)|
            master_pid = fork || Master.run(name)
            slave_pids = conf.slaves.times.map{ fork || Slave.run(name) }

            log "  Started '#{name}' Master: #{master_pid}"
            log "  Started '#{name}' Slaves: #{slave_pids * ", "}"

            acc[name]  = { :master => master_pid, :slaves => slave_pids }
            acc
          end
        end

        # -----------------------------------------------------------------------------
        def stop_workers
          log "Stopping Ticker: #{@ticker}"
          Process.kill :TERM, @ticker if Process.running? @ticker

          log "Stopping Workers"
          @workers.each do |name, pid_hash|
            log "  Stopping '#{name}' Master: #{pid_hash[:master]}"
            log "  Stopping '#{name}' Slaves: #{pid_hash[:slaves] * ", "}"
            Process.kill :TERM, pid_hash[:master] if Process.running? pid_hash[:master]
            Process.kill :TERM, *pid_hash[:slaves]
          end

          Process.waitall
        end

        # -----------------------------------------------------------------------------
        def register_pids
          PID.write :ticker  => @ticker
          PID.write :masters => @workers.values.map{|h| h[:master] }
          @workers.values.each{|h| PID.write :"#{h[:master]}_slaves" => h[:slaves] }
        end

        # -----------------------------------------------------------------------------
        def unregister_pids
          PID.delete :ticker
          PID.delete :masters
          @workers.values.each{|h| PID.delete :"#{h[:master]}_slaves" }
        end

      # private
    end
  end # module Workers
end # module Minions
