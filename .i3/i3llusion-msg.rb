#!/usr/bin/env ruby 
# vim:ts=2:sw=2:et:
#
require 'socket'

UNIXSocket.open("#{File.dirname(ENV.fetch('I3SOCK'))}/i3llusion.ipc") do
  it.send(ARGV.last, 0)
end
