require 'rubygems'
require 'mechanize'
require 'date'
require 'active_record'
require 'nokogiri'
require 'open-uri'
require 'pp'
require 'set'

ActiveRecord::Base.establish_connection(
	:adapter => "postgresql",
	:database  => "test_shard",
	:schema_search_path => "t1",
	:host => "localhost",
	:username => "test",
	:password => "123456"
)
class Post < ActiveRecord::Base

	def postable?
		!self.download.empty?
	end
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

sites = [
	{:url => "http://www.elforro.com", :login => "http://www.elforro.com/login.php?do=login", 
	:pname => "http://www.elforro.com/newthread.php?do=newthread&f=149", :paction => "newthread.php?do=postthread&f=149",
	:user => "gihana", :pass => "228787"},
	{:url => "http://rapdrop.com", :login => "login.php?do=login", 
	:pname => "http://rapdrop.com/newthread.php?do=newthread&f=35", :paction => "newthread.php?do=postthread&f=35",
	:user => "dicochno", :pass => "228787"},
	{:url => "http://www.expresshare.com", :login => "http://www.expresshare.com/login.php?do=login", 
	:pname => "http://www.expresshare.com/newthread.php?do=newthread&f=9", :paction => "newthread.php?do=postthread&f=9",
	:user => "gihana", :pass => "228787"}
]

site = sites[1]

	agent = Mechanize.new do |a|
	    a.follow_meta_refresh = true
	end

#	hname = "http://www.pcdoctor.gen.tr"
#	loginaction = "login.php?do=login" || "#{hname}/login.php?do=login"
#	forumid = 100
#	pname = "#{hname}/newthread.php?do=newthread&f=#{forumid}"
#	paction = "newthread.php?do=postthread&f=#{forumid}" || "#{hname}/newthread.php?do=postthread&f=#{forumid}"
	#http://www.teluga.com/newthread.php?do=newthread&f=31
	 

	page = agent.get(site[:url])
	
	login_form = page.form_with(:action => site[:login])

	login_form['vb_login_username'] = site[:user]
	login_form['vb_login_password'] = site[:pass]
	login_form['vb_login_md5password_utf'] = ""
	login_form['vb_login_md5password'] = ""

	page = agent.submit login_form

	#Display welcome message if logged in
	#puts page.parser.xpath("/html/body/div/table/tr/td[2]/div/div").xpath('text()').to_s.strip

	#temp_jar = agent.cookie_jar.jar
	#puts temp_jar
	
	posts = Post.all.select {|p| p.postable? == true}
	if posts then
	posts.each do |p|
		puts p.title
		page2 = agent.get(site[:pname])
		
		File.open("testpage1.html","w").write(page2.content)
		post_form = page2.form_with(:name => "vbform")		
		if post_form then
			puts site[:url]
			post_form['subject'] = p.title.gsub("Details for ","").gsub("."," ")   if post_form['subject']
			post_form['message'] = p.to_post.gsub("torrent","site") if post_form['message']
			post_form['prefixid'] = "f_03" if  post_form['prefixid']
			page2 = agent.submit post_form 
			sleep 60
		end
	end
	end




