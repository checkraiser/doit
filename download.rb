#encoding: utf-8

require 'rubygems'
require 'mechanize'
require 'date'
require 'nokogiri'
require 'open-uri'
require './config'



agent = Mechanize.new do |a|
    a.follow_meta_refresh = true
    a.user_agent_alias = 'Mac Safari'
end
page = agent.get("http://uploaded.net/#login")
login_form = page.form_with(:action => "io/login") 

login_form['id'] = PREUSER
login_form['pw'] = PREPASS

agent.submit login_form

agent.pluggable_parser.default = Mechanize::Download


page2 = agent.get('http://ul.to/4jjntv1w')
File.open("testdownload.html","w").write(page2.content)
download_form = page2.forms.first
puts download_form.action
#puts download_form['method']
agent.get(download_form.action).save("4041.txt")