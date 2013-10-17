# -----------------------------------------------------------------------------
module Minions
  # -----------------------------------------------------------------------------
  # Root Worker - the father of all worker processes!
  # This should work as a monitor, keeping all sub-processes behaving nicelly...
  class RootWorker
    def self.run
      self.new.run
    end

    def finalize
      # TODO - finalize...
    end

    # -----------------------------------------------------------------------------
    def run
      ticker_pid = fork || TickerWorker.run

      master_pids = Minions.workers.map do |minion_name, _|
        fork || MasterWorker.run(minion_name)
      end
      puts "RootWorker: #{Process.pid}, TickerWorker: #{ticker_pid}, MasterWorkers: #{master_pids * ", "}"

      trap(:TERM) do
        puts "killing ticker"
        Process.kill :TERM, ticker_pid

        master_pids.each do |pid|
          puts "Stopping #{pid}"
          Process.kill :TERM, pid
        end
      end

      Process.waitall
      finalize
      exit 0
    end

  end
end # module Minions
