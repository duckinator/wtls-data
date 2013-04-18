#!/usr/bin/env ruby

# Yes, this is ugly. I know.

require 'open-uri'
require 'nokogiri'
require 'uri'
require 'time'

id = ARGV[0]

if !id || id.empty?
  puts "Usage: #$0 [name]"
  puts
  puts "For example, `#$0 disclaimer` will get \"01. disclaimer.pdf\""
  exit 1
end

root = 'http://scott-olson.org/_why/'

doc = Nokogiri::HTML(open(root).read)

doc.css('tr').each do |x|
  anchors = x.css('a')
  next unless anchors && anchors.length > 0
  file = anchors[0]['href']

  next unless file.end_with?('.pdf')
  date = Time.parse(x.css('.m')[0].text)
  date_dir = date.strftime('%Y/%m/%d')

  number, name = URI.decode(file).split('.')
  name.strip!

  next unless name.downcase == id

  local_file = "#{number.to_s.rjust(3, '0')}_#{name.upcase}.pdf"
  local_dir  = File.join(File.dirname(__FILE__), 'tsion', date_dir)
  full_local_file = File.join(local_dir, local_file)

  url = root + file

  print "Saving #{url} to #{full_local_file}... "
  File.open(full_local_file, 'wb') do |f|
    f.write open(url).read
  end
  puts "Done."
end
