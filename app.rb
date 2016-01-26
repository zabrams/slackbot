require 'sinatra'
require 'httparty'
require 'json'

post '/gateway' do
  slack_response = params[:text].gsub(params[:trigger_word], '').strip.downcase
  slack_response = slack_response.split

  puts slack_response

  case slack_response[0]
    when 'hacker-news'
      resp = get_json("https://hacker-news.firebaseio.com/v0/topstories.json?print=pretty")
      resp = resp[0..9]
      message = "Here are the top 10 HN stories: \n"
      
      resp.each do |story_id|
        story_url = "https://hacker-news.firebaseio.com/v0/item/#{story_id}.json?print=pretty"
        story_response = get_json(story_url)
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
        message = "Couldn't find that ticker :("
      end

    #NYT top stories api
    when 'nyt'
      unless slack_response[1]
        slack_response[1] = "home"
      end

      if slack_response[1] == "popular"
        resp = get_json("http://api.nytimes.com/svc/mostpopular/v2/mostviewed/all-sections/1.json?api-key=77c81381526472f019114e6da8e2a40f:14:61565219")
        resp = resp['results']
        message = "Most popular stories from the NYT: \n"

        resp.each do |story|
          message += "*#{story["title"]}*, #{story["url"]} \n"
        end
      else  
        if resp = get_json("http://api.nytimes.com/svc/topstories/v1/#{slack_response[1]}.json?api-key=3e34bef4efc68cca88cb6b727c4beb6d:14:61565219") 
          resp = resp['results']
          message = "Top stories from the NYT #{slack_response[1]}: \n"

          resp.each do |story|
            message += "*#{story["title"]}*, #{story["url"]} \n"
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

def get_json(url)
  response = HTTParty.get(url)
  if response.parsed_response.first[0] == "Error"
    return false
  else
    response = JSON.parse(response.body)
    return response
  end
end
