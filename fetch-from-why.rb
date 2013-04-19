#!/usr/bin/env ruby

require 'open-uri'
require 'time'
require 'fileutils'

class Why
  def update
    root = 'http://whytheluckystiff.net/'
    page = open(root).read

    page.lines.grep(/SPOOL/).each do |line|
      url, date = line.strip.split("\t")

      name = url.split('/')[-1]
      date = Time.parse(date)
      date_dir = date.strftime('%Y/%m/%d')

      files = Dir[File.join(File.dirname(__FILE__), 'PCL', date_dir, '*')]
      if files.any? {|x| x.split('_', 2)[-1].upcase == name.upcase }
        puts "Skipping #{name.upcase} (already exists)."
        next
      end

      number = `find PCL -type f | sed 's/.*\\\///' | cut -d '_' -f 1 | sort -u`.split("\n").last.to_i + 1

      local_file = "#{number.to_s.rjust(3, '0')}_#{name.upcase}"
      local_dir  = File.join(File.dirname(__FILE__), 'PCL', date_dir)
      FileUtils.mkdir_p(local_dir)
      full_local_file = File.join(local_dir, local_file)

      print "Saving #{root + url} to #{full_local_file}... "
      File.open(full_local_file, 'wb') do |f|
        f.write open(root + url).read
      end
      puts "Done."
    end
  end
end
