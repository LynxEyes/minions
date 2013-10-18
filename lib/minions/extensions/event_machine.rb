# ------------------------------------------------------------------------------
# This adds the ability to add timers with milisecond resolution to EventMachine
# Note: Blunt copy of "add_timer", just removed the "to_i" conversion...

module EventMachine

  def self.add_timer_ms *args, &block
    interval = args.shift
    code = args.shift || block
    if code
      s = add_oneshot_timer(interval.to_f * 1000)
      @timers[s] = code
      s
    end
  end

end # module EventMachine
