#!/usr/bin/env ruby
require "socket"

# Silent exit
trap("INT") { exit }

socket = UNIXSocket.new "/tmp/dump_server.sock"

# socket.write "count!"
# socket.close_write

p socket.read