#!/usr/bin/env ruby

# Yes, this is ugly. I know.

require 'open-uri'
require 'nokogiri'
require 'uri'
require 'time'

def fetch_all
  print "Start fetching."
  $skipped ||= []
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

    local_file = "#{number.to_s.rjust(3, '0')}_#{name.upcase}.pdf"
    local_dir  = File.join(File.dirname(__FILE__), 'tsion', date_dir)
    full_local_file = File.join(local_dir, local_file)

    if File.exist?(full_local_file)
      if !$skipped.include?(name)
        puts "Skipping #{name} (already exists)."
        $skipped << name
      end
    else
      url = root + file

      print "Saving #{url} to #{full_local_file}... "
      File.open(full_local_file, 'wb') do |f|
        f.write open(url).read
      end
    end
  end
  puts "Done."
end

loop do
  fetch_all
  sleep 30
end
