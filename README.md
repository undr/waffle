# Waffle

An abstract flow publisher and subscriber.

[![Build Status](https://secure.travis-ci.org/undr/waffle.png?branch=master)](http://travis-ci.org/undr/waffle)

It supports the following transports: 

- RabbitMQ
- Redis

## Configuration

Insert in your Gemfile:

    gem 'bunny' # for RabbitMQ transport
    gem 'hiredis' # for Redis transport
    gem 'redis', require: ['redis', 'redis/connection/hiredis'] # for Redis transport
    gem 'waffle', :gem => 'git://github.com/undr/waffle.git'
    
**Warning!** Gem 'waffle' must follow gems 'bunny' and 'redis' in Gemfile.

Create config file:

    production:
      transport: rabbitmq
      encoder: marshal
      url: amqp://anyhost.com:5678

and load it:

    Waffle.configure(:path => 'config/waffle.yml')

You also can configure Waffle programmatically:

    Waffle.configure({
      :transport => 'redis',
      :url => 'redis://localhost:6379/0',
      :encoder => 'json'
    })

or:

    Waffle.configure do
      default do |config|
        config.transport = 'redis'
        config.url = 'redis://localhost:6379/0'
        config.encoder = 'json'
      end
    end

### Multitransport config

You can use many transports for organising your messaging system. Just add to config file `queues` section:

    production:
      transport: rabbitmq
      encoder: marshal
      url: amqp://anyhost.com:5678
      queues:
        redis_name:
          transport: redis
          encoder: json
          url: redis://localhost:6379/0

or programmatically:

    Waffle.configure({
      :transport => 'redis',
      :url => 'redis://localhost:6379/0',
      :encoder => 'json',
      :queues => {
        :redis_name => {
          :transport => 'redis',
          :url => 'redis://localhost:6380/0',
          :encoder => 'json',
        }
      }
    })

    # or

    Waffle.configure do
      default do |config|
        config.transport = 'redis'
        config.url = 'redis://localhost:6379/0'
        config.encoder = 'json'
      end

      queue(:redis_name) do |config|
        config.transport = 'redis'
        config.url = 'redis://localhost:6380/0'
        config.encoder = 'json'
      end
    end


## Usage

### Event 

When you want to performan event, just insert this code in place, where it must occur:

    Waffle::Event.occurred 'message'

You can attach meta data to event like this:

    Waffle::Event.occurred {'user_id' => 13, 'user_name' => 'Joshua'}, :event_name => 'index_page_load'

or like this:

    Waffle::Event.occurred 'bingo!', :event_name => 'index_page_load'

or:
    
    Waffle::Event.occurred 'message', :event_name => 'index_page_load', :queue => :experimental_queue

### Pub/Sub

    Waffle.publish('event.name', message_hash_or_string)
    
    Waffle.subscribe('event.name') do |message_type, message_hash_or_string|
      pp message_type
      pp message_hash_or_string
    end

### Multitransport usage

    Waffle.queue(:redis_name).publish('event.name', message_hash_or_string)

    Waffle.queue(:redis_name).subscribe('event.name') do |message_type, message_hash_or_string|
      pp message_type
      pp message_hash_or_string
    end

### Reconnect

Don't care about any reconnects when transport server is down. Waffle just waits for server ready and reconnects automatically.
