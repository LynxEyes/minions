module Minions
  module PartialMethods
    def partial_method m_name, *args
      proc{|*proc_args| method(m_name.to_sym).call *(args + proc_args) }
    end
  end # module PartialMethods
end # module Minions
