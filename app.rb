require 'sinatra'
require 'httparty'
require 'json'
require 'sinatra/activerecord'
require_relative "news"
require_relative "polls"
require_relative "cal"

db = URI.parse('postgres://zach@localhost/cal_users')

ActiveRecord::Base.establish_connection(
  :adapter  => db.scheme == 'postgres' ? 'postgresql' : db.scheme,
  :host     => db.host,
  :username => db.user,
  :password => db.password,
  :database => db.path[1..-1],
  :encoding => 'utf8'
)

post '/gateway' do
  user_name = params[:user_name].downcase
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
    when 'cal'
      message = Cal.check_status(user_name)
    else
      puts "OH NO THERE WAS AN ERROR"
      message = "I accept the below commands: \n"+
                "butler news [source] \n"+
                "butler poll [option1] [option2] ... [option9] \n"+
                "that's all i got .... for now."
  end
  puts message
  respond_message message 
end

def respond_message message
  content_type :json
  {:text => message}.to_json
end


