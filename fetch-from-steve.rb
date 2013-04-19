#!/usr/bin/env ruby

require 'open-uri'
require 'fileutils'

class Steve
  PDF_REGEXP = %r[https://dl.dropboxusercontent.com/u/5764687/why/.*.pdf]

  def self.puts(*args)
    args.map{|x| "[fetch/steve] #{x}" }
    Kernel.puts(*args)
  end

  def find_pcl(name)
    Dir[File.join(File.dirname(__FILE__), 'PCL', '*', '*', '*', "*#{name}")].first
  end

  def find_dir(name)
    name = name.split('_', 2)[-1].gsub('.pdf', '')
    pcl  = find_pcl(name)
    dir  = File.dirname(pcl).gsub('/PCL/', '/steveklabnik/')
    dir
  end

  def find_full_path(file)
      dir = find_dir(file)
      File.join(dir, file)
  end

  def update
    links = open('http://madx.me/why.txt').read.lines.grep(PDF_REGEXP).map{|x| x.scan(PDF_REGEXP) }.flatten.uniq

    accepted = links.reject do |x|
      file = x.split('/')[-1]
      File.exist?(find_full_path(file))
    end

    rejected = (links - accepted).map do |url|
      url.split('/')[-1].split('_', 2)[1].gsub('.pdf', '')
    end

    puts "Skipping: #{rejected.join(', ')}."
    puts "Downloading #{accepted.length}."

    accepted.each do |url|
      local_file = find_full_path(url.split('/')[-1])

      FileUtils.mkdir_p(File.dirname(local_file))

      print "Saving #{url} to #{local_file}... "
      File.open(local_file, 'wb') do |f|
        f.write open(url).read
      end
      puts "Done."
    end
  end
end
