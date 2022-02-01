require 'open-uri'
require 'nokogiri'

file_name = ARGV[0]
dictionary_name = ARGV[1] || 'words'

found_words = []

File.read(file_name).each_line do |line|
  words = line.split
  words.each do |word|
    word.chomp!
    found_words << word.downcase if word.length == 5
  end
end

puts "Found words: #{found_words.size}\n"

require_relative '../db'
$redis.sadd(dictionary_name, found_words)
