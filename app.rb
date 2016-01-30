require 'sinatra'
require 'httparty'
require 'json'
require 'sinatra/activerecord'
require_relative "news"
require_relative "polls"
require_relative "cal"

db = URI.parse('postgres://kaxjttbjtsdvpb:f-CWBQHdi0DGS-KJwak7kbPwS5@ec2-54-225-197-143.compute-1.amazonaws.com:5432/d464ch0dradbq5')

ActiveRecord::Base.establish_connection(
  :adapter  => db.scheme == 'postgres' ? 'postgresql' : db.scheme,
  :host     => db.host,
  :username => db.user,
  :password => db.password,
  :database => db.path[1..-1],
  :encoding => 'utf8'
)

post '/gateway' do
  user_id = params[:user_id]
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
      if user = Cal_users.find_by(user_id: user_id)
        #check is cal request is valid
        message = "yay, you're a user"
      else
        message = Cal_users.auth_user(user_id)
      end
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


