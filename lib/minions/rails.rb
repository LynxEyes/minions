# -----------------------------------------------------------------------------
def Minions minion_name
  Minions::MinionStub.new minion_name
end

# =============================================================================
module Minions

  # -----------------------------------------------------------------------------
  # When using Rails, Minions env must be the same as Rails
  Minions[:env] = Rails.env || ENV["RAILS_ENV"] || "development"

  # =============================================================================
  class MinionStub

    attr_reader :minion_name, :minion_config
    # -----------------------------------------------------------------------------
    def initialize minion_name
      @minion_config = Minions.minion minion_name
      @minion_name = minion_name
    end

    # -----------------------------------------------------------------------------
    def method_missing method_name, *args
      enqueue method_name, *args
    end

    # -----------------------------------------------------------------------------
    private
      # -----------------------------------------------------------------------------
      def redis
        @redis ||= Redis.new(:url => Minions.redis_url)
      end

      # -----------------------------------------------------------------------------
      def enqueue task, *args
        redis.publish minion_config.channel, MultiJson.dump({:task => task, :args => args})
      end

    # end private
  end # class MinionStub

  # @@railtie_instance = Railtie.new
  # mattr_accessor :railtie_instance
  # =============================================================================
  # def self.enqueue worker, task, *args

  # end

end
