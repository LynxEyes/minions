require 'yaml'
require 'logger'
require 'fileutils'
# -----------------------------------------------------------------------------
require 'redis'
require 'multi_json'
require 'eventmachine'
require 'chronic'
# require 'oj' # remove this..
# -----------------------------------------------------------------------------
require "minions/version"
require 'minions/utils'
require 'minions/extensions'
require 'minions/worker_logger'
require 'minions/pid_files'

module Minions
  # -----------------------------------------------------------------------------
  autoload :Minion     , "minions/minion"
  autoload :MinionConfig,"minions/minion_config"
  autoload :CronTrigger, "minions/cron_trigger"

  module Workers
    autoload :Ticker, "minions/workers/ticker"
    autoload :Root  , "minions/workers/root"
    autoload :Master, "minions/workers/master"
    autoload :Slave , "minions/workers/slave"
  end

  # -----------------------------------------------------------------------------
  # -----------------------------------------------------------------------------
  # APP Configurations...
  def self.config
    @config ||= YAML.load_file('config/minions.yml').tap do |cfg|
      cfg[:env]         ||= "development"
      cfg[:logto]       ||= "./log/minions.log"
      cfg[:redis_url]   ||= "redis://localhost:6379"
      cfg[:minions_dir] ||= "#{File.expand_path "."}/minions"
    end
  end

  def self.[] idx
    idx.is_a?(Symbol) && self.respond_to?(idx) ? self.send(idx) : config[idx]
  end

  def self.[]= idx, value
    config[idx] = value
  end

  def self.minions
    @minions ||= config[:minions].reduce({}) do |acc, (name, config)|
      acc[name] = MinionConfig.new name, config
      acc
    end
  end
  def self.minion name
    minions[name]
  end

  def self.method_missing mname, *args
    if config.has_key?(mname) && args.empty?
      config.fetch mname
    else
      super
    end
  end

  def self.respond_to? mname
    config.has_key?(mname) || super
  end

  # -----------------------------------------------------------------------------
  # -----------------------------------------------------------------------------
  def self.load_worker name
    filename  = "#{Minions.minions_dir}/#{name}.rb"
    classname = name.to_s.classify
    load filename
    Object.const_get classname
  rescue NameError => e
    raise NameError.new("Expected #{filename} to define #{classname} class", e)
  end

  # -----------------------------------------------------------------------------
  # Process related methods
  def self.running?
    root_pid = Minions::PID.read :root
    root_pid && Process.running?(root_pid)
  end

  # -----------------------------------------------------------------------------
  def self.start
    Minions::PID.write :root => Process.pid
    Workers::Root.run
  end

  # -----------------------------------------------------------------------------
  def self.stop
    root_pid = Minions::PID.read :root
    root_pid && Process.kill(:TERM, root_pid)
    Minions::PID.delete :root
  end

end


# -----------------------------------------------------------------------------
if defined? Rails
  require 'minions/rails'
end

