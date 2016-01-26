require 'sinatra'
require 'httparty'
require 'json'

require_relative "news"

post '/gateway' do
  slack_command = params[:trigger_word].strip.downcase
  slack_response = params[:text].gsub(params[:trigger_word], '').strip.downcase
  slack_response = slack_response.split

  puts slack_response
  puts slack_command

  case slack_command
    when 'news:'
      message = News.fetch_news(slack_response)
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


