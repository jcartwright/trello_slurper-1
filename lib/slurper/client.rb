require 'typhoeus'

module Slurper
  class Client
    attr_reader :write_token, :list_id

    def get_trello_write_token
      if Slurper::Config.trello_write_token.present?
        @write_token = Slurper::Config.trello_write_token
      else
        url = "https://trello.com/1/authorize?key=#{Slurper::Config.trello_application_key}&name=Slurper%20for%20Trello&expiration=1day&response_type=token&scope=read%2Cwrite"
        puts "You must provide a write-enabled Trello API token."
        puts "Ensure you're logged into Trello, then press the <ENTER> key to open a browser window to fetch this token."
        _ = gets
        `open "#{url}"`
        puts "Please paste your token."
        @write_token = gets.strip
      end
    end

    def create_list
      url = "https://trello.com/1/boards/#{Slurper::Config.trello_board_id}/lists?key=#{Slurper::Config.trello_application_key}&token=#{write_token}&name=Slurper%20Import"
      @list_id = JSON.parse(Typhoeus.post(url).body)["id"]
    end

    def create_card(story)
      url = "https://trello.com/1/lists/#{list_id}/cards?key=#{Slurper::Config.trello_application_key}&token=#{write_token}"
      Typhoeus.post url, body: story.to_post_params
    end

    def validate_write_token
      url = "https://trello.com/1/tokens/#{write_token}?key=#{Slurper::Config.trello_application_key}"
      response = Typhoeus.get(url).body.strip
      raise "Invalid Token '#{write_token}'" if response =~ /invalid token/
    end
  end
end
