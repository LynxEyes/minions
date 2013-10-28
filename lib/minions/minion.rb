module Minions

  class Minion
    include WorkerLogger
    include SimpleDelegation
    # =============================================================================
    class << self
      # -----------------------------------------------------------------------------
      def minion_name name = nil
        (name && @minion_name = name.to_sym) || @minion_name || self.name.underscore.to_sym
      end

      # -----------------------------------------------------------------------------
      def minion_config
        Minions.minion minion_name
        # @minion_config ||= MinionConfig.new(minion_name)
      end

      # -----------------------------------------------------------------------------
      def channel; minion_config.channel; end
      def queue  ; minion_config.queue  ; end

      # -----------------------------------------------------------------------------
      def slaves
        minion_config.slaves
      end

      # -----------------------------------------------------------------------------
      def master event = :default, opts = {}, &block
        if block_given?
          @masters ||= {}
          @masters[event.to_sym] = block
        else
          @masters
        end
      end

      # -----------------------------------------------------------------------------
      def slave event = :default, opts = {}, &block
        if block_given?
          @slaves ||= {}
          @slaves[event.to_sym] = block
        else
          @slaves
        end
      end

      # -----------------------------------------------------------------------------
      def initialize &block
        (block_given? && @initialize_block = block) || @initialize_block
      end

      # -----------------------------------------------------------------------------
      def finalize &block
        (block_given? && @finalize_block = block) || @finalize_block
      end

    end # class methods

    # =============================================================================
    def initialize worker
      @worker = worker
    end

    attr_reader :worker
    delegate :enqueue, :to => :worker

  end # class Minion

end # module Minions
