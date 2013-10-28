module Minions

  class MinionConfig
    attr_accessor :name, :config

    def initialize name, config
      @name   = name.to_sym
      @config = config
    end

    # -----------------------------------------------------------------------------
    def channel; "##{name}"; end

    # -----------------------------------------------------------------------------
    def queue  ;  "#{name}"; end

    # -----------------------------------------------------------------------------
    # generic accessor to every property set on the minions.yml config file for
    # a particular minion
    # Ex: m = MinionConfig.new :dashboard_generator
    #     m.task_schedules # => {:task_one => '*/5 * * * * *', :task_two => '0 */5 * * * *'}
    def method_missing method, *args
      if args.empty? and config.has_key? method
        config[method]
      else
        super
      end
    end

    # -----------------------------------------------------------------------------
    def task_schedules
      config[:task_schedules] || []
    end
    # -----------------------------------------------------------------------------
    def slaves
      config[:slaves] || 0
    end

  end # class MinionConfig

end # module Minions
