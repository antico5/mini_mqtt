# MiniMqtt

A full ruby implementation of the client side of MQTT protocol. 

The philosophy behind this gem is to keep the code as minimal and tidy as possible, and to completely avoid dependencies.

Project is currently under development.

## Installation

Clone this repo and include it to your load path. This project isn't published at rubygems yet.

## How to test

  rake test

## Usage

```ruby
require 'mini_mqtt'


# Create client instance
# Possible params are host, port, user, password, keep_alive (seconds), client_id, and clean_session
# client_id defaults to random client id
# clean_session defaults to true
# keep_alive defaults to 10

client = MiniMqtt::Client.new host: 'localhost'

# Establish connection
client.connect

# Check at any time if client is connected
puts client.connected?

# Publish messages
client.publish '/topic', 'hello'
client.publish '/other_topic', 'retained_message', retain: true

# Subscribe to topics
client.subscribe '/topic', '/other_topic'

# Get messages
client.get_message do |msg, topic|
  puts "Received #{ msg } on topic #{ topic }"
end

# Gracefully disconnect
client.disconnect

```
