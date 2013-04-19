#!/usr/bin/env ruby

# Steve Klabnik's personal twitter creeperbot. <3
#
# Searches his timeline for _why-related PDFs,
# then sends the links to #_why on FreeNode.


require 'cinch'
require 'open-uri'

class WhyBot < Cinch::Bot
  def initialize
    @sent = []
    @first = true

    super() do
      configure do |c|
        c.server = 'irc.freenode.net'
        c.port = 6667
        c.channels = ['#_why']
        c.nick = 'ILIEKSTEVE'
      end
    end
  end

  def fetch_latest
    open('https://twitter.com/steveklabnik').read.lines.map{|x| x.scan(%r[https://dl.dropboxusercontent.com/u/5764687/why/[^"]+]) }.flatten.reverse.uniq
    #"# gedit, you suck at %r[].
  end

  def send_latest
    urls = fetch_latest - @sent
    if @first && urls.length > 5
      @sent += urls[0...-5]
      urls = urls[-5..-1]
      @first = true
    end

    urls.each do |url|
      @sent << url

      name = url.split('/')[-1].split('_', 2)[-1].gsub('.pdf', '')
      channels[0].send "#{name}: #{url}"

      sleep 1
    end
  end
end

bot = WhyBot.new

Cinch::Timer.new(bot, :interval => (60 * 3)) do
  bot.send_latest
end

bot.start
