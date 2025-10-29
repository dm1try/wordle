# frozen_string_literal: true

require_relative '../db'

puts "Initializing Redis dictionaries..."

# Check if dictionaries are already populated
words_en_count = $redis.scard('words_en')
available_words_en_count = $redis.scard('available_words_en')
words_ru_count = $redis.scard('words')
available_words_ru_count = $redis.scard('available_words')

if words_en_count > 0 && available_words_en_count > 0 && words_ru_count > 0 && available_words_ru_count > 0
  puts "Dictionaries already populated:"
  puts "  - words_en: #{words_en_count} words"
  puts "  - available_words_en: #{available_words_en_count} words"
  puts "  - words (ru): #{words_ru_count} words"
  puts "  - available_words (ru): #{available_words_ru_count} words"
  puts "Skipping initialization."
  exit 0
end

puts "Dictionaries are empty. Adding initial words..."

# Add basic words for English dictionary
basic_en_words = %w[
  plain crane slate train brink think trick track stack toast those about
  arise arose stare share shark sharp smart start stair alarm claim frame
  blame flame plant grand brand bread break dream cream clean clear learn
]

$redis.sadd('words_en', basic_en_words)
$redis.sadd('available_words_en', basic_en_words)

# Add basic words for Russian dictionary
basic_ru_words = %w[
  слово точка место время право город голос народ ночка книга жизнь земля
  вопро число берег путь кровь театр месяц очень война связь право писец
]

$redis.sadd('words', basic_ru_words)
$redis.sadd('available_words', basic_ru_words)

puts "✓ Added #{basic_en_words.size} English words"
puts "✓ Added #{basic_ru_words.size} Russian words"
puts ""
puts "NOTE: These are just starter words. For a complete dictionary, use:"
puts "  bundle exec ruby setup/seed_dictionary.rb <url> <css_selector> <dictionary_name>"
puts ""
puts "Dictionaries initialized successfully!"
