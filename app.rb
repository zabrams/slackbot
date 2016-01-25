require 'sinatra'
require 'httparty'
require 'json'

post '/gateway' do
  message = params[:text].gsub(params[:trigger_word], '').strip

  case message[0]
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

    when 'stock'
      resp = HTTParty.get('http://dev.markitondemand.com/Api/v2/Quote', :query => {:symbol => "#{message[1]}"})
      resp = resp.parsed_response
      if resp = resp["StockQuote"]
        message = "#{resp["Name"]} \n
          #{resp["Symbol"]} \n
          #{resp["LastPrice"]} \n
          #{resp["Change"]} \n
          #{resp["MarketCap"]} \n
          #{resp["Timestamp"]}
          "
      else 
        message = "Couldn't find that ticket symbol :("
      end

      respond_message message 
  end
end

def respond_message message
  content_type :json
  {:text => message}.to_json
end