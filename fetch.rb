require 'rss'
require 'open-uri'

url = 'http://rlslog.net/category/music/albums/feed/'
open(url) do |rss|
  feed = RSS::Parser.parse(rss)
  puts "Title: #{feed.channel.title}"
  feed.items.each do |item|
    puts item.inspect
  end
end