#check if have connected account

#if yes - check cal avail 

#if no 
class Cal_users < ActiveRecord::Base
	
end


#message = "How many accounts do you want to connect?"

#Do the below to connect all the accounts

#initial call to google to get access, it returns the utl 


#then -- 


 
#this is the output - show the code and url 
#output ===> {"device_code"=>"YGQM-VAPC4/_z8ez6M-FrwF467maYCFcwoczOmggRSECMLTDoRph_I", 
# 	"user_code"=>"YGQM-VAPC", "verification_url"=>"https://www.google.com/device", 
# 	"expires_in"=>1800, "interval"=>5} 
 #Show code and url to user. this is how they auth



# call to poll google once authed - 
#when users types - "all set" - we then poll google to get tokens 
#resp2 = HTTParty.post("https://www.googleapis.com/oauth2/v4/token",
#	:query => { :client_id => '530054264762-oquhikmnri528k9nmr5ucqk1shgiahnq.apps.googleusercontent.com', 
#		:code => "YGQM-VAPC4/_z8ez6M-FrwF467maYCFcwoczOmggRSECMLTDoRph_I", 
#		:grant_type => "http://oauth.net/grant_type/device/1.0", 
#		:client_secret => 'QIUx2_-swnRBS15GBjMwVAzg'})
# MAKE SURE TO PUT CLIENT SECRET IN NEW FILE THAT OTHERS CANNOT ACCESS


#This sends back the access_token, refresh_token, and expiry time
#I should save this info to a DB
#Then every time the user sends me a request, i check: 
#Is token expired? 
#If so, use refresh to get new one 
#If not get access_token 
#Then make Google API call