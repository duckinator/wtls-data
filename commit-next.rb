#!/usr/bin/env ruby

require 'shellwords'

def find(dir)
  (Dir["#{dir}/*/*/*/*"] + Dir["#{dir}/*/*/*/*/*"]).reject do |x|
    File.directory?(x)
  end
end

def find_file(dir = '*', name)
  Dir[File.join(File.dirname(__FILE__), dir, '*', '*', '*', "*#{name}*")].first
end

# Find next uncommitted PCL + tsion/ + steveklabnik/ grouping.
def find_next
  first = `git status -s`.lines.map{|x| x.gsub('?? ', '') }.grep(/^(PCL|tsion|steveklabnik)\//).first.strip

  name = first.split('/')[-1].split('_', 2)[1]

  pcl   = find_file('PCL', name)
  tsion = find_file('tsion', name)
  steve = find_file('steveklabnik', name)

  [name, [pcl, tsion, steve]]
end

def commit_next
  name, files = find_next
  files = files.reject(&:nil?).map{|x| Shellwords.escape(x) }.join(' ')
  msg = Shellwords.escape("Add #{name}.")
  `git add #{files} && git commit -m #{msg}`
end

commit_next
