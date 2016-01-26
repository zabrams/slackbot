module Polls
	def Polls.create_poll(poll_options)
		numbers_to_name = {
			9 => "nine",
		    8 => "eight",
		    7 => "seven",
		    6 => "six",
		    5 => "five",
		    4 => "four",
		    3 => "three",
		    2 => "two",
		    1 => "one"
		}
		message = ""

		if poll_options.count > 9
			message = "Why're you creating a poll this large - it's just unnecessary. Limit it to 9 - it'll be better for everyone. :smile:"
		else
			n = 0
			poll_options.each do |option|
				n += 1
				message += ":#{numbers_to_name[n]}: #{option} \n"
			end
		end

		return message
		#take all the options, create a \n list starting with the :one: emoji.
		#the trick will be to convert the number to the right spelled emoji
		#can support up to 9 options
	end
end