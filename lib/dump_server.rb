#!/usr/bin/env ruby
#
# see: http://www.jstorimer.com/blogs/workingwithcode/8136295-screencast-faster-rails-test-runs-with-unix

require "socket"

listener = UNIXServer.new "/tmp/dump_server.sock"

# Clean up after yourself
parent_process_id = Process.pid
at_exit {
  File.unlink "/tmp/dump_server.sock" if Process.pid == parent_process_id
}

# Make a thread to prevent blocking of the main thread
Thread.new do
  loop do
    client = listener.accept
    # command = client.read

    # fork to minimize the probe effect
    pid = fork do
      $stdout.reopen client
      p ObjectSpace.count_objects
    end
    Process.wait pid
    client.close
  end
end