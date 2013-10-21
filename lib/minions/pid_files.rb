module Minions
  module PID

    DEFAULT_PID_DIR = './tmp/pids/minions'

    # -----------------------------------------------------------------------------
    def self.pid_folder
      FileUtils.mkdir_p DEFAULT_PID_DIR unless File.exist? DEFAULT_PID_DIR
      DEFAULT_PID_DIR
    end

    def self.write_slaves pids
      write :"#{Process.pid}_slaves" => pids
    end

    # -----------------------------------------------------------------------------
    def self.write hash
      hash.each do |name, pids|
        filename, pids = pid_filename(name), Array(pids)
        File.write filename, pids.join("\n")
      end
    end

    # -----------------------------------------------------------------------------
    def self.read_slaves
       read :"#{Process.pid}_slaves"
    end

    # -----------------------------------------------------------------------------
    def self.read *names
      if 1 == names.length
        pid names.first
      else
        names.reduce({}) do |acc, name|
          acc[name] = pid(name)
          acc
        end
      end
    end

    # -----------------------------------------------------------------------------
    def self.delete_slaves
       delete :"#{Process.pid}_slaves"
    end

    # -----------------------------------------------------------------------------
    def self.delete *names
      names.each do |name|
        File.delete pid_filename(name)
      end
    end

    # -----------------------------------------------------------------------------
    def self.pid_filename name
      "#{pid_folder}/#{String(name)}.pid"
    end

    # -----------------------------------------------------------------------------
    def self.pid name
      filename = pid_filename name
      File.exist?(filename) && File.read(filename).to_i
    end

    # -----------------------------------------------------------------------------
    def self.running? name
      (pid_no = pid(name)) && pid_no > 0 && Process.running?(pid_no)
    end

  end # module PID
end # module Minions
