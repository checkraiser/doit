#encoding: utf-8

require 'rubygems'
require 'mechanize'
require 'date'
require 'nokogiri'
require 'open-uri'
require 'json'
require './config'

outputfile = ARGV[0] || "topic/output.txt"
msize = 10

agent = Mechanize.new do |a|
    a.follow_meta_refresh = true
    a.user_agent_alias = 'Mac Safari'
    a.idle_timeout = 0.9
end
page = agent.get("http://uploaded.net/#login")
login_form = page.form_with(:action => "io/login") 

login_form['id'] = USERNAME
login_form['pw'] = PASSWORD

agent.submit login_form



def get_count(agent)
	res = agent.post("http://uploaded.net/api/file/list",{:folder => 0, :max => 1, :nav => "undefined",
	:q => nil, :start => 0} ,{'X-Requested-With' => 'XMLHttpRequest',
	'Content-Type' =>  'application/x-www-form-urlencoded; charset=UTF-8',
	'Accept' => 'text/javascript, text/html, application/xml, text/xml, */*'})	
	body = JSON.parse(res.body)
	return  body["files_count"]
end

msize = get_count(agent)
si = msize/500
puts "getting ..." + si.to_s + " files"

open(outputfile,"w") do |f|
	(si+1).times do |index|
		puts "getting page " + index.to_s
		start = 500 * index
		res = agent.post("http://uploaded.net/api/file/list",{:folder => 0, :max => 500, :nav => "undefined",
			:q => nil, :start => start} ,{'X-Requested-With' => 'XMLHttpRequest',
			'Content-Type' =>  'application/x-www-form-urlencoded; charset=UTF-8',
			'Accept' => 'text/javascript, text/html, application/xml, text/xml, */*'})
		puts "completed :)"

		body = JSON.parse(res.body)

		files = body["files"]
	
		files.each do |file|
			f << "http://uploaded.net/file/" + file["id"] + "/" + file["filename"] + "\n"
		end
	end
end