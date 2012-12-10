$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require 'rubygems'
require 'bundler/setup'
require 'waffle/version'
require 'multi_json'
require 'time'

module Waffle
  extend self
  module Transports
    autoload :Base, 'waffle/transports/base'
    autoload :Rabbitmq, 'waffle/transports/rabbitmq' if defined?(Bunny)
    autoload :Redis, 'waffle/transports/redis' if defined?(::Redis)

    module_function
    def create config
      "Waffle::Transports::#{config.transport.camelize}".constantize.new(config)
    end
  end

  autoload :Config, 'waffle/config'
  autoload :Event, 'waffle/event'

  class Config
    autoload :Node, 'waffle/config'
  end

  module Encoders
    autoload :Json, 'waffle/encoders/json'
    autoload :Marshal, 'waffle/encoders/marshal'
  end

  def reset_config!
    config.reset_config! if config
  end

  def configure options = nil, &block
    if block_given?
      Config.class_eval(&block)
    else
      options = {:path => 'config/waffle.yml'} unless options
      Config.load!(options)
    end
  end

  def config
    Config if Config.configured?
  end

  def queue name = :default
    config.queues[name] or raise "Transport '#{name}' is not configured"
  end

  def publish flow = 'events', message = ''
    raise "Waffle is not configured" unless Config.configured?
    config.queues[:default].publish(flow, message)
  end

  def subscribe flow = '', &block
    raise "Waffle is not configured" unless Config.configured?
    config.queues[:default].subscribe(flow, &block)
  end

  def method_missing meth, *args
    if Config.configured?
      config.queues[:default].send(meth, *args)
    else
      super
    end
  end
end

unless defined?(ActiveSupport::Inflector)
  class String
    def constantize
      names = self.split('::')
      names.shift if names.empty? || names.first.empty?

      constant = Object
      names.each do |name|
        constant = constant.const_defined?(name) ? constant.const_get(name) : constant.const_missing(name)
      end
      constant
    end

    def camelize
      string = sub(/^[a-z\d]*/){$&.capitalize}
      string.gsub(/(?:_|(\/))([a-z\d]*)/){ "#{$1}#{$2.capitalize}" }.gsub('/', '::')
    end
  end
end

unless defined?(ActiveSupport)
  class Hash
    def symbolize_keys!
      keys.each do |key|
        self[(key.to_sym rescue key) || key] = delete(key)
      end
      self
    end

    def symbolize_keys
      dup.symbolize_keys!
    end
  end
end
