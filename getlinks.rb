require 'rubygems'
require 'mechanize'
require 'date'
require 'active_record'
require 'sqlite3'
require 'nokogiri'
require 'open-uri'
require 'pp'
require 'set'
ActiveRecord::Base.establish_connection(
	:adapter => "sqlite3",
	:database  => "db.sqlite3"
)
class Post < ActiveRecord::Base
	def to_post
		res = ""
		res += self.title.gsub("Details for ", "").gsub("."," ") + "\n"
		res += self.description + "\n"
		res += "---- Download ---- \n"
		res += "[code]"
		links = JSON.parse(self.download)
		links.each do |l|
			res += l
		end
		res += "[/code]"
	end
end

co = {}

File.readlines("links.txt").each do |line|
	key = line.split("/").last
	k = key[0..key.length-15]
	co[k] ||= []
	co[k] << line
end

co.each do |k,v|
	puts k
	p = Post.where(:torrent => k).first	
	if p then
		puts "Done: #{k}"
		p.download = v.to_json
		p.save
	end	
end

