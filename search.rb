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
end
links = Set.new
agent = Mechanize.new
begin
  Post.all.each do |post|
	
	search = post.torrent
	links << "---- #{search} ----"
	puts search	
	doc = Nokogiri::XML(open("http://api.filestube.com/?key=759bfc1cbc7d0f85d001c983b5155979&phrase=#{search}"))
	puts doc
	num = doc.xpath('/answer/results/hitsTotal/text()')
	puts num.to_s
	num.to_s.to_i.times do |t|
		puts t
		link1 = doc.xpath("/answer/results/hits[#{t+1}]/link/text()")		
		page = agent.get(link1.to_s)
		upString = page.parser.xpath("/html/body/div[2]/div[3]/div[5]/div[3]/div/a/text()").to_html
		links << upString
		puts upString
	end	
  end
rescue
	$stdout = File.open("results.txt", "w")
	pp links.to_a
end