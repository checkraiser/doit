require 'rubygems'
require 'mechanize'
require 'date'
require 'active_record'
require 'sqlite3'
currentDate = DateTime.now.to_date.strftime("%d-%m-%Y")

class Post < ActiveRecord::Base
	def to_post
		res = ""
		res += self.title + "\n"
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


agent = Mechanize.new
filename = ARGV[0]
links = []
lines = IO.readlines(filename).map do |line|
  links << line.split(" ").first
end
dirName = "D:\\dspace"

system("mkdir #{dirName}\\temp\\#{currentDate}")
#page = agent.get("#{url}/top/#{cat}")

#numPost = page.parser.xpath("/html/body/div[2]/div[2]/table/tr")


links.each do |link|
	post = Post.new
	#upString = page.parser.xpath("/html/body/div[2]/div[2]/table//tr[#{i+1}]/td[2]/div[1]/a")[0]
	#itemName = upString['title'].to_s
	#	post.title = itemName
	link_torrent =  link.gsub("http://thepiratebay.sx/torrent/","http://torrents.thepiratebay.sx/") + ".torrent"
	fileName = link.split("/").last
	post.title = fileName.split(/_/).splirt(/./).join(" ")
	post.torrent = fileName
	outputName = fileName + ".torrent"
	agent.get(link_torrent).save_as("#{dirName}\\t\\#{outputName}")
	system("mkdir #{dirName}\\temp\\#{currentDate}\\#{fileName}")
	system("bitcomet \"#{dirName}\\t\\#{outputName}\" -o \"#{dirName}\\temp\\#{fileName}\" -s")
	page = agent.get(link)	
	infoStr = page.parser.xpath("/html/body/div[2]/div[2]/div/div/div/div[2]/div[6]/pre/text()").to_html
	post.description = infoStr
	post.published = false
	post.note = ""
	post.download = ""
	begin post.save rescue puts "Error saving" end
end

