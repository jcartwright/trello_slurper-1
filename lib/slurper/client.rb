require 'typhoeus'

module Slurper
  class Client
    attr_reader :write_token, :list_id

    def initialize
      @write_token = Slurper::Config.trello_write_token
    end

    def get_trello_write_token(overwrite_config=true)
      url = "https://trello.com/1/authorize?key=#{Slurper::Config.trello_application_key}&name=Slurper%20for%20Trello&expiration=30days&response_type=token&scope=read%2Cwrite"
      puts "You must provide a write-enabled Trello API token."
      puts "Ensure you're logged into Trello, then press the <ENTER> key to open a browser window to fetch this token."
      _ = gets
      `open "#{url}"`
      puts "Please paste your token."
      @write_token = gets.strip

      # =================================================================================
      # BUG: When a file name is passed, the gets.strip somehow picks up 'story_type:'.
      # This causes the script to continue executing, but creates an invalid write token
      # =================================================================================

      if overwrite_config == true && write_token =~ /^[a-zA-Z0-9]{50,70}$/
        Slurper::Config.store(:trello_write_token, write_token)
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

      token_data = JSON.parse(response)
      date_created = Time.parse(token_data['dateCreated'])
      date_expires = Time.parse(token_data['dateExpires'])
      puts "-- token valid from #{date_created} to #{date_expires}"
    end
  end
end
