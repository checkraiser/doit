path = 'listtorrent.txt'

lines = IO.readlines(path).map do |line|
  puts line.split(" ").first
end