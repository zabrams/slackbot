class Gmail

	def Gmail.auth_user
		resp = HTTParty.post("https://accounts.google.com/o/oauth2/device/code", 
			:query => {:client_id=>'530054264762-oquhikmnri528k9nmr5ucqk1shgiahnq.apps.googleusercontent.com', 
			:scope => 'https://www.googleapis.com/auth/calendar'})
		resp = JSON.parse(resp.body)
		message = "Visit this url: #{resp['verification_url']} \n"+
				"Enter this code: #{resp['user_code']} \n"+
				"When you're finished, please type 'butler cal finished'"
		return message
	end
end