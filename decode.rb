#!/usr/bin/env ruby

def decode(file)
  code = `pdf2txt #{file}`
  chars = code.chars.reject { |c| c =~ /\s/ }.uniq
  frequencies = Hash[chars.map { |c| [c, code.scan(c).size] }]
  codepoints = Hash[chars.map { |c| [c, c.codepoints.first] }]
  chars = chars.sort_by { |c| frequencies[c] }.reverse
 
  substitutions = Hash[chars.map { |c| [c, c]} ]
  key = "etosaihnrudlmfcw,ygpvkb.\"\"qWjO'?TILx()A'B\"N"
  key.chars.each_with_index { |c, i| substitutions[chars[i]] = c }
 
  decoded = code.chars.map { |c| substitutions[c] || c }.join
  decoded
end

def file_list
  dir = File.join(File.dirname(__FILE__), 'steveklabnik', '2013', '**', '*.pdf')
  Dir[dir].sort
end

def decode_all
  file_list.each do |file|
    puts decode(file)
    gets
  end
end

decode_all
