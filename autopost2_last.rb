#encoding: utf-8

require 'rubygems'
require 'mechanize'
require 'date'
require 'nokogiri'
require 'open-uri'
require './sites'

frum = ARGV[0].to_i || 0# forum muon post

burst = 0
ispost = true
rtime = 3 # so lan post lại nếu bị lỗi


sleeptime =  SITES[frum][:sleeptime] || 30 # thoi gian giua moi post
burstsize = SITES[frum][:burstsize] || 200
bursts = []
if burst != 0 then
	Dir["burst/*.txt"].each do |file|
		File.readlines(file).each do |line|
			bursts << line
		end
	end
	bb = bursts.each_slice(burstsize).to_a
	le = bb.length
end
posts = []
Dir["topic/*.txt"].each do |file|
	File.readlines(file).each_with_index do |line, index|
		if burst != 0 then 
			id = index % le	
		else 
			id = index 
		end
		title = line.split("/").last.gsub("_"," ").gsub(".rar.html","").gsub("."," ")
		desc = ""
		desc += "[code]#{line}[/code]"
		if burst != 0 then
			desc += "[code]"
			bb[id].each do |li|
				desc += li + "\n"
			end		
			desc += "[/code]"
		end
		posts << {:title => title, :desc => desc}
	end
end
site = SITES[frum]

agent = Mechanize.new do |a|
    a.follow_meta_refresh = true
    a.user_agent_alias = 'Mac Safari'
    a.idle_timeout = 0.9
end



page = agent.get(site[:url])
File.open("homepage.html","w").write(page.content)
login_form = page.form_with(:action => site[:login]) || page.form_with(:id => "navbar_loginform") || page.form_with(:id => "login") || page.form_with(:action => site[:url] + site[:login])

login_form['vb_login_username'] = site[:user] if login_form['vb_login_username']
login_form['vb_login_password'] = site[:pass] if login_form['vb_login_password']
login_form['vb_login_md5password_utf'] = "" if login_form['vb_login_md5password_utf']
login_form['vb_login_md5password'] = "" if login_form['vb_login_md5password']
login_form['ips_username'] = site[:user] if login_form['ips_username']
login_form['ips_password'] = site[:pass] if login_form['ips_password']
login_form['username'] = site[:user] if login_form['username']
login_form['password'] = site[:pass] if login_form['password']


page = agent.submit login_form

File.open("login.html","w").write(page.content) unless ispost


def autop(agent,site,p,index)
	begin
		puts p[:title]
		page2 = agent.get(site[:pname])
		File.open("main.html","w").write(page2.content)
		
		post_form = page2.form_with(:name => "vbform")	|| page2.form_with(:id => "postingform") || page2.form_with(:action => site[:paction]) || page2.form_with(:action => site[:url] + site[:paction])
		
		if post_form then
			puts site[:url]
			post_form['subject'] = p[:title]  if post_form['subject']
			post_form['message'] = p[:desc] if post_form['message']
			post_form['prefixid'] = site[:prefix] if  post_form['prefixid']
			post_form['TopicTitle'] = p[:title] if post_form['TopicTitle'] #ipb
			post_form['Post'] = p[:desc] if post_form['Post'] 	# ipb
			post_form['message_new'] = p[:desc] if post_form['message_new'] # mybb
			page3 = agent.submit post_form 
			if index == 0 then 
				File.open("result.html","w").write(page3.content)
			end			
		end
	rescue Exception => e		
		raise e
	end
end

if ispost then
	posts.each_with_index do |p, index|
		begin
			autop(agent,site,p,index)	
			sleep sleeptime
		rescue Exception => e
			puts e
			rtime.times do |ii|
				puts "repost times #{ii+1}"
				autop(agent,site,p,index)
				sleep sleeptime
			end
		end
	end

else
	begin
			title = "Hello from Australia"
			mess = "Hello all of you :))"
			puts "Post thu voi tieu de hello"
			page2 = agent.get(site[:pname])
			File.open("main-test.html","w").write(page2.content)
			
			post_form = page2.form_with(:name => "vbform")	|| page2.form_with(:id => "postingform") || page2.form_with(:action => site[:paction])
			
			if post_form then
				puts site[:url]
				post_form['subject'] = title  if post_form['subject']
				post_form['message'] = mess if post_form['message']
				post_form['prefixid'] = site[:prefix] if  post_form['prefixid']
				post_form['TopicTitle'] =title if post_form['TopicTitle']
				post_form['Post'] = mess if post_form['Post']
				post_form['message_new'] = mess if post_form['message_new']
				page3 = agent.submit post_form 
				 
				File.open("result-test.html","w").write(page3.content)
								
			end	
		rescue Exception => e
			puts e
			sleep 2
		end
end

