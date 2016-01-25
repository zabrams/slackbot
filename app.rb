require 'sinatra'
require 'httparty'
require 'json'

post '/gateway' do
  slack_response = params[:text].gsub(params[:trigger_word], '').strip
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
        message += "Story #{n}: #{story_response["title"]}, #{story_response["url"]} \n"
      end
      puts message
      respond_message message

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
      puts message
      respond_message message

    #NYT top stories api
    when 'nyt'
      resp = HTTParty.get('http://api.nytimes.com/svc/topstories/v1/home.json?api-key=3e34bef4efc68cca88cb6b727c4beb6d:14:61565219')
      resp = JSON.parse resp.body
      resp = resp['results']
      n = 0
      message = "Here are the top stories from the NYT: \n"

      resp.each do |story|
        n += 1
        message += "Story #{n}: #{story["title"]}, #{story["url"]} \n"
      end

      puts message
      respond_message message

    else 
      message = "I didn't understand that :(\n"+
                "I have the below commands:\n"+
                "hacker-news - Get top 10 HN articles\n"+
                "stock TICKER - Get latest stock price and change\n"+
                "-------------the end-------------"

      puts message
      respond_message message 
  end
end

def respond_message message
  content_type :json
  {:text => message}.to_json
end