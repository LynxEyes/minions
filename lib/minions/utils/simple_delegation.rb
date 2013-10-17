module Minions
  module SimpleDelegation
    module ClassMethods

      def delegate *m_names
        opts   = m_names.pop
        target = opts[:to]
        m_names.each do |m_name|
          if target.is_a? Symbol
            define_method m_name do |*args|
              self.send(target).send m_name, *args
            end
          else
            define_method m_name do |*args|
              target.send m_name, *args
            end
          end
        end
      end

    end # ClassMethods

    # =============================================================================
    def self.included base
      base.extend ClassMethods
    end

  end # module SimpleDelegation
end # module Minions
