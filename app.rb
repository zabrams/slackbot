require 'sinatra'
require 'httparty'
require 'json'

post '/gateway' do
  slack_response = params[:text].gsub(params[:trigger_word], '').strip.downcase
  slack_response = slack_response.split

  puts slack_response

  case slack_response[0]
    when 'hacker-news'
      resp = HTTParty.get("https://hacker-news.firebaseio.com/v0/topstories.json?print=pretty")
      resp = JSON.parse resp.body
      resp = resp[0..9]
      n = 0
      message = "Here are the top 10 HN stories: \n"
      
      resp.each do |story_id|
        n += 1
        story_url = "https://hacker-news.firebaseio.com/v0/item/#{story_id}.json?print=pretty"
        story_response = HTTParty.get(story_url)
        story_response = JSON.parse story_response.body
        message += "*#{story_response["title"]}*, #{story_response["url"]} \n"
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
        message = "Couldn't find that ticket symbol :("
      end

    #NYT top stories api
    when 'nyt'
      unless slack_response[1]
        slack_response[1] = "home"
      end

      if slack_response[1] == "popular"
        resp = HTTParty.get("http://api.nytimes.com/svc/mostpopular/v2/mostviewed/all-sections/1.json?api-key=77c81381526472f019114e6da8e2a40f:14:61565219")
        resp = JSON.parse resp.body
        resp = resp['results']
        n = 0
        message = "Most popular stories from the NYT: \n"

        resp.each do |story|
          n += 1
          message += "*#{story["title"]}*, #{story["url"]} \n"
        end
      else  
        resp = HTTParty.get("http://api.nytimes.com/svc/topstories/v1/#{slack_response[1]}.json?api-key=3e34bef4efc68cca88cb6b727c4beb6d:14:61565219")
        if resp.parsed_response.first[0] == "Error"
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
        else 
          resp = JSON.parse resp.body
          resp = resp['results']
          n = 0
          message = "Top stories from the NYT #{slack_response[1]}: \n"

          resp.each do |story|
            n += 1
            message += "*#{story["title"]}*, #{story["url"]} \n"
          end
        end
      end
    else 
      message = "I didn't understand that :(\n"+
                "I have the below commands:\n"+
                "hacker-news - Get top 10 HN articles\n"+
                "stock TICKER - Get latest stock price and change\n"+
                "-------------the end-------------"
  end
  puts message
  respond_message message 
end

def respond_message message
  content_type :json
  {:text => message}.to_json
end