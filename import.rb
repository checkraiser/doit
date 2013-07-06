#encoding: utf-8

require 'rubygems'
require 'mechanize'
require 'date'
require 'nokogiri'
require 'open-uri'
require 'json'
require './config'

outputfile = ARGV[0] || "output.txt"

def transf(str)
	str2 = str.gsub("\"","").gsub("{","").split("},")

	res = []
	str2.each do |si|
		temp = {}
		str3 = si.split(",")
		str3.each do |ki|
			ss = ki.split(":")
			temp[ss[0]] = ss[1]
		end
		res << temp
	end

	return res 
end

agent = Mechanize.new do |a|
    a.follow_meta_refresh = true
    a.user_agent_alias = 'Mac Safari'
end
page = agent.get("http://uploaded.net/#login")
login_form = page.form_with(:action => "io/login") 

login_form['id'] = USERNAME
login_form['pw'] = PASSWORD

agent.submit login_form


links = []


Dir["import/*.txt"].each do |file|
	File.readlines(file).each_with_index do |line, index|
		links << line
	end
end
links2 = links.join("\n")

puts "importing ..."
res = agent.post("http://uploaded.net/io/import",{:urls => links2} ,{'X-Requested-With' => 'XMLHttpRequest',
	'Content-Type' =>  'application/x-www-form-urlencoded; charset=UTF-8',
	'Accept' => 'text/javascript, text/html, application/xml, text/xml, */*'})
puts "completed :)"

body = transf(res.body)

open(outputfile,"w") do |f|
	body.each do |row| 
		f << "http://uploaded.net/file/" + row["newAuth"] + "/" + row["filename"] +"\n"  unless row["err"]
	end
end

