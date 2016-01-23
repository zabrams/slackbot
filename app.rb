require 'sinatra'
require 'httparty'
require 'json'

post '/gateway' do
  message = params[:text].gsub(params[:trigger_word], '').strip

  case message
    when 'hacker-news'
      resp = HTTParty.get("https://hacker-news.firebaseio.com/v0/topstories.json?print=pretty")
      resp = JSON.parse resp.body
      resp = resp[0..9]
      
      story1 = resp[0]
      story_url = "https://hacker-news.firebaseio.com/v0/item/#{story1}.json?print=pretty"
      story_response = HTTParty.get(story_url)
      story_response = JSON.parse story_response.body
      respond_message "Title: #{story_response["title"]}, #{story_response["url"]}"
  end
end

def respond_message message
  content_type :json
  {:text => message}.to_json
end