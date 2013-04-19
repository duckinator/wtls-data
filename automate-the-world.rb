#!/usr/bin/env ruby

require './fetch-from-why'
require './fetch-from-tsion'
require './fetch-from-steve'
require './commit-next'

objs = [Tsion, Why, Steve, Commit].map {|x| x.new }

loop do
  objs.map(&:update)
  sleep 60
end
