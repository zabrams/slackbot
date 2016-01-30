class Gmail

	def Gmail.auth_user
		resp = HTTParty.post("https://accounts.google.com/o/oauth2/device/code", 
			:query => {:client_id=>'530054264762-oquhikmnri528k9nmr5ucqk1shgiahnq.apps.googleusercontent.com', 
			:scope => 'https://www.googleapis.com/auth/calendar'})
		resp = JSON.parse(resp.body)
		@auth_code = resp['device_code']
		message = "Visit this url: #{resp['verification_url']} \n"+
				"Enter this code: #{resp['user_code']} \n"+
				"When you're finished, please type 'butler cal finished'"
		return message
	end

	def Gmail.add_user(user_id)
		resp = HTTParty.post("https://www.googleapis.com/oauth2/v4/token",:query => { :client_id => '530054264762-oquhikmnri528k9nmr5ucqk1shgiahnq.apps.googleusercontent.com', :code => @auth_code, :grant_type => "http://oauth.net/grant_type/device/1.0", :client_secret => 'QIUx2_-swnRBS15GBjMwVAzg'})
		resp = JSON.parse(resp.body)
		expiry_time = DateTime.now + (resp['expires_in'] / 86400.0)
		new_user = {user_id: user_id, refresh_token: resp['refresh_token'], access_token: resp['access_token'], expires_at: expiry_time}
		if Cal_users.create(new_user)
			message = "yay, your account is linked"
		else 
			message = "uh oh something went wrong"
		end
		return message
	end 

end