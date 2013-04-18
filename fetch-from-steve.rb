#!/usr/bin/env ruby

require 'open-uri'

PDF_REGEXP = %r[https://dl.dropboxusercontent.com/u/5764687/why/.*.pdf]

def find_pcl(name)
  Dir[File.join(File.dirname(__FILE__), 'PCL', '*', '*', '*', "*#{name}")].first
end

def find_dir(name)
  name = name.split('_')[-1].gsub('.pdf', '')
  pcl  = find_pcl(name)
  dir  = File.join('steveklabnik', File.dirname(pcl).gsub('PCL/', ''))
  dir
end

def find_full_path(file)
    dir = find_dir(file)
    File.join(File.dirname(__FILE__), dir, file)
end

def fetch_all
  links = open('http://madx.me/why.txt').read.lines.grep(PDF_REGEXP).map{|x| x.scan(PDF_REGEXP) }.flatten.uniq

  accepted = links.reject do |x|
    file = x.split('/')[-1]
    File.exist?(find_full_path(file))
  end
  rejected = (links - accepted).map do |url|
    url.split('/')[-1].split('_')[1].gsub('.pdf', '')
  end

  puts "Skipping: #{rejected.join(', ')}."
  puts "Downloading #{accepted.length}."

  accepted.each do |url|
    local_file = find_full_path(url.split('/')[-1])

    print "Saving #{url} to #{local_file}... "
    File.open(local_file, 'wb') do |f|
      f.write open(url).read
    end
    puts "Done."
  end
end

loop do
  fetch_all
  sleep 60
end

