# MiniMqtt

A full ruby implementation of the client side of MQTT protocol. 

The philosophy behind this gem is to keep the code as minimal and tidy as possible, and to completely avoid dependencies.

  cloc lib
  
  ---------------------------------------------------------------------
  Language         files          blank        comment           code
  ---------------------------------------------------------------------
  Ruby                 6            103             14            449
  ---------------------------------------------------------------------

## Installation

Clone this repo and include it to your load path. This project isn't published at rubygems yet.

## How to test
You need mosquitto server installed in order tu run integration tests.

  sudo apt-get install mosquitto

  rake test

## Usage

```ruby
require 'mini_mqtt'
```

### Create client instance
Possible params are host, port, user, password, keep_alive (seconds), client_id, and clean_session
client_id defaults to random client id
clean_session defaults to true
keep_alive defaults to 10

```ruby
client = MiniMqtt::Client.new host: 'test.mosquitto.org'
```

### Establish connection
Options are will_topic, will_message, will_retain(false) and will_qos(0)

client.connect

You can check at any time if client is connected

puts client.connected?

### Publish messages

```ruby
# Regular publish
client.publish '/topic', 'hello'

# Publish with retain
client.publish '/other_topic', 'retained_message', retain: true

# Publish with qos
client.publish '/qos_topic', 'message', qos: 1
```

# Subscribe to topics

```ruby
# Single topic
client.subscribe '/topic'

# Multiple topics
client.subscribe '/topic', '/other_topic'

# Specifying max qos for topic (default 0)
client.subscribe '/topic', '/qos_topic' => 1
```

# Get messages
The caller of these methods are blocked until a message arrives, or the connection is lost.

```ruby
# Get a single message
msg = client.get_message
puts msg.message, msg.topic, msg.qos, msg.retain, msg.packet_id, msg.dup

# Get messages in an infinite loop. Breaks if connection is lost.
client.get_messages do |msg, topic|
  puts "Received #{ msg } on topic #{ topic }"
end
```

# Gracefully disconnect
client.disconnect
```
