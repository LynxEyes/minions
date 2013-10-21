# =============================================================================
Process.instance_eval do
  # -----------------------------------------------------------------------------
  # Checks if a process is running by sending it a 0 signal.
  # If there is no process with "pid" then "Process.kill" raises an exception
  # that we can interpret as "the given process does not exist", thus, not running
  unless self.respond_to? :running?
    def running? pid
      Process.kill 0, pid # if pid exists, this returns a "truthy value"
    rescue Errno::ESRCH => e
      false
    end
  end # respond_to? :running?

  # -----------------------------------------------------------------------------
  unless self.respond_to? :launch_daemon
    DAEMON_DEFAULTS = {:chdir => true, :close_std_channels => true}
    def launch_daemon options = {}, &block
      return if fork # Parent exits, child continues.
      Process.setsid # Become session leader.
      exit if fork   # Zap session leader.

      Signal.trap("HUP"){exit(1)}
      options = DAEMON_DEFAULTS.merge options

      if options[:chdir]
        Dir.chdir "/" # Release old working directory.
      end

      # File.umask 0000 # Ensure sensible umask.

      if options[:close_std_channels]
        # Free descriptors...
        STDIN.reopen  '/dev/null'
        STDOUT.reopen '/dev/null', 'a'
        STDERR.reopen '/dev/null', 'a'
      end

      block.call
    end
  end # respond_to? :launch_daemon

end
