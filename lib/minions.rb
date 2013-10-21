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
# -----------------------------------------------------------------------------

module Minions
  # -----------------------------------------------------------------------------
  autoload :Minion     , "minions/minion"
  autoload :CronTrigger, "minions/cron_trigger"

  module Workers
    autoload :Ticker, "minions/workers/ticker"
    autoload :Root  , "minions/workers/root"
    autoload :Master, "minions/workers/master"
    autoload :Slave , "minions/workers/slave"
  end

  # -----------------------------------------------------------------------------
  # Config related accessors
  def self.config
    @config ||= YAML.load_file('config/minions.yml')
  end

  def self.workers
    config[:workers]
  end

  def self.number_of_slaves minion_name
    workers[minion_name][:slaves]
  end

  def self.redis_url
    config[:redis_url] || "redis://localhost:6379"
  end

  def self.workers_dir
    config[:workers_dir] || "workers/"
  end

  # -----------------------------------------------------------------------------
  def self.load_worker name
    filename  = "#{File.expand_path "."}/workers/#{name}.rb"
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
  def self.start; Workers::Root.run; end

  # -----------------------------------------------------------------------------
  def self.stop
    root_pid = Minions::PID.read :root
    root_pid && Process.kill(:TERM, root_pid)
  end

end
