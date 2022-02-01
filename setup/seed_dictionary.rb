# Usage example:
#  bundle exec ruby setup/seed_dictionary.rb "https://ru.wiktionary.org/wiki/Приложение:Список_частотных_слов_русского_языка_(2013)" "table.wikitable"
#

require 'open-uri'
require 'nokogiri'

uri = URI.encode(ARGV[0])
doc = Nokogiri::HTML(URI.open(uri).read)
doc = doc.css(ARGV[1]) if ARGV[1]
dictionary_name = ARGV[2] || 'words'

found_words = []
doc.text.each_line do |line|
  words = line.split
  words.each do |word|
    word.chomp!
    found_words << word.downcase if word.length == 5
  end
end

puts "Found words: #{found_words.size}\n"

require_relative '../db'
$redis.sadd(dictionary_name, found_words)
