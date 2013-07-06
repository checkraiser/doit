

str = "{auth:\"dufmdasz\",newAuth:\"2gx4u14k\",filename:\"VA-Girls_On_Top-2CD-2011-VAG.rar\",size:\"214,44 MB\"},{auth:\"cjmjatt3\",newAuth:\"71e1bywn\",filename:\"Yukmouth_Presents-The_Regime-The_Last_Dragon-The_Album-2013-CR.rar\",size:\"119,11 MB\"},"
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

puts res.inspect