require 'yaml'
require 'logger'
# -----------------------------------------------------------------------------
require 'redis'
require 'multi_json'
# require 'oj' # remove this..
require 'eventmachine'
require 'chronic'
# -----------------------------------------------------------------------------
require "minions/version"
require 'minions/utils'
require 'minions/extensions'
require 'minions/worker_logger'
require 'minions/minion'
# -----------------------------------------------------------------------------

module Minions
  autoload :Minion,       "minions/minion"
  autoload :CronTrigger,  "minions/cron_trigger"
  autoload :TickerWorker, "minions/ticker_worker"
  autoload :RootWorker,   "minions/root_worker"
  autoload :MasterWorker, "minions/master_worker"
  autoload :SlaveWorker,  "minions/slave_worker"

  def self.root_path
    File.expand_path("../../",__FILE__)
  end

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

  def self.load_worker name
    filename  = "#{File.expand_path "."}/workers/#{name}.rb"
    classname = name.to_s.classify
    load filename
    Object.const_get classname
  rescue NameError => e
    raise NameError.new("Expected #{filename} to define #{classname} class", e)
  end

  # -----------------------------------------------------------------------------
  def self.run; RootWorker.run; end
  # -----------------------------------------------------------------------------
end
