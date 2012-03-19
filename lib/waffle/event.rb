require 'singleton'

module Waffle
  class Event
    include Singleton

    class << self
      # Syntactic sugar ^_^
      def occured(*args)
        self.instance.occured(*args)
      end
    end

    def config
      @config ||= Waffle::Configuration.new
    end

    def transport
      @transport ||= Waffle::Base.new eval("Waffle::Strategies::#{config.strategy.capitalize}").new(config)
    end

    def occured(event_name = 'event', event_data = nil)
      unless event_data.is_a? Hash
        event_data = {'body' => event_data.to_s}
      end

      event_data.merge!({'occured_at' => Time.now})

      transport.publish event_name, Waffle::Utils.encode(event_data)
    end

  end
end
