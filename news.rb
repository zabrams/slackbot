module News

	def News.fetch_news(slack_response)
		case slack_response[0]
		    when 'hacker-news'
		      resp = News.get_json("https://hacker-news.firebaseio.com/v0/topstories.json?print=pretty")
		      resp = resp[0..9]
		      message = "Here are the top 10 HN stories: \n"
		      
		      resp.each do |story_id|
		        story_url = "https://hacker-news.firebaseio.com/v0/item/#{story_id}.json?print=pretty"
		        story_response = News.get_json(story_url)
		        message += News.create_headlines(story_response)
		      end
		    when 'stock'
		      resp = HTTParty.get('http://dev.markitondemand.com/Api/v2/Quote', :query => {:symbol => "#{slack_response[1]}"})
		      resp = resp.parsed_response
		      if resp = resp["StockQuote"]
		        message = "Company: #{resp["Name"]}\n"+
		        "Ticker: #{resp["Symbol"]}\n"+
		        "Price: $#{resp["LastPrice"]}\n"+
		        "Change: #{resp["Change"]}\n"+
		        "Mkt Cap: #{resp["MarketCap"]}\n"+
		        "Last Trade: #{resp["Timestamp"]}"
		      else 
		        message = "Couldn't find that ticker :("
		      end

		    #NYT top stories api
		    when 'nyt'
		      unless slack_response[1]
		        slack_response[1] = "home"
		      end

		      if slack_response[1] == "popular"
		        resp = News.get_json("http://api.nytimes.com/svc/mostpopular/v2/mostviewed/all-sections/1.json?api-key=77c81381526472f019114e6da8e2a40f:14:61565219")
		        resp = resp['results']
		        message = "Most popular stories from the NYT: \n"

		        resp.each do |story|
		          message += News.create_headlines(story)
		        end
		      else  
		        if resp = News.get_json("http://api.nytimes.com/svc/topstories/v1/#{slack_response[1]}.json?api-key=3e34bef4efc68cca88cb6b727c4beb6d:14:61565219") 
		          resp = resp['results']
		          message = "Top stories from the NYT #{slack_response[1]}: \n"

		          resp.each do |story|
		            message += News.create_headlines(story)
		          end
		        else
		          message = "I support to below nyt commands: \n"+
		                    "popular\n"+
		                    "home\n"+
		                    "world\n"+
		                    "national\n"+
		                    "politics\n"+
		                    "nyregion\n"+
		                    "business\n"+
		                    "opinion\n"+
		                    "technology\n"+
		                    "science\n"+
		                    "health\n"+
		                    "sports\n"+
		                    "arts\n"+
		                    "fashion\n"+
		                    "dining\n"+
		                    "travel\n"+
		                    "magazine\n"+
		                    "realestate"
		        end
		      end
		    else 
		      message = "I didn't understand that :(\n"+
		                "I have the below commands:\n"+
		                "hacker-news - Get top 10 HN articles\n"+
		                "stock [ticker] - Get latest stock price and change\n"+
		                "nyt [section] - Get top 10 HN articles\n"+
		                "-------------the end-------------"
		end
		puts message
  		return message
	end

	def News.get_json(url)
  		response = HTTParty.get(url)
  		if response.parsed_response.first[0] == "Error"
    		return false
  		else
    		response = JSON.parse(response.body)
    		return response
  		end
	end

	def News.create_headlines(hash)
  		message = "*#{hash["title"]}*, #{hash["url"]} \n"
	end
  
end



