#!/usr/bin/env ruby

require 'open-uri'
require 'time'

$old    = nil

def fetch_all
  root = 'http://whytheluckystiff.net/'
  page = open(root).read

  page.lines.grep(/SPOOL/).each do |line|
    url, date = line.strip.split("\t")

    name = url.split('/')[-1]
    date = Time.parse(date)
    date_dir = date.strftime('%Y/%m/%d')

    number = 1
    files = Dir[File.join(File.dirname(__FILE__), 'PCL', date_dir, '*')]
    if files.any? {|x| x.split('_')[-1].upcase == name.upcase }
      puts "Skipping #{name.upcase} (already exists)."
      next
    end

    old = files.map do |x|
      x.split('/').last.split('_').first
    end.map(&:to_i).max
    number = old + 1 if old.is_a?(Numeric)

    local_file = "#{number.to_s.rjust(3, '0')}_#{name.upcase}"
    local_dir  = File.join(File.dirname(__FILE__), 'PCL', date_dir)
    full_local_file = File.join(local_dir, local_file)

    print "Saving #{root + url} to #{full_local_file}... "
    File.open(full_local_file, 'wb') do |f|
      f.write open(root + url).read
    end
    puts "Done."
  end
end

loop do
  fetch_all
  sleep 30
end
