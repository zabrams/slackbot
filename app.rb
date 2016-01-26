require 'sinatra'
require 'httparty'
require 'json'
require_relative "news"
require_relative "polls"

post '/gateway' do
  slack_response = params[:text].gsub(params[:trigger_word], '').strip.downcase
  slack_response = slack_response.split
  req_type = slack_response.shift

  puts req_type
  puts slack_response

  case req_type
    when 'news'
      message = News.fetch_news(slack_response)
    when 'poll'
      message = Polls.create_poll(slack_response)
    else
      puts "OH NO THERE WAS AN ERROR"
  end
  puts message
  respond_message message 
end

def respond_message message
  content_type :json
  {:text => message}.to_json
end


