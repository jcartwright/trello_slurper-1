module Slurper
  class Engine < Struct.new(:story_file)

    attr :client

    def initialize(*args)
      super(*args)
      @client = Slurper::Client.new
      @client.get_trello_write_token
      @client.validate_write_token
      @client.create_list
    rescue => e
      puts e
    end

    def stories
      @stories ||= YAML.load(yamlize_story_file).map { |attrs| Slurper::Story.new(attrs) }
    end

    def process
      puts "Validating story content"
      stories.each(&:valid?)

      puts "Preparing to slurp #{stories.size} stories into Trello..."
      stories.each_with_index do |story, index|
        if client.create_card(story)
          puts "#{index+1}. #{story.name}"
        else
          puts "Slurp failed. #{story.error_message}"
        end
      end
    end

    protected

    def yamlize_story_file
      IO.read(story_file).
        gsub(/^/, "    ").
        gsub(/    ==.*/, "-").# !ruby/object:Slurper::Story\n  attributes:").
        gsub(/    description:$/, "    description: |")
    end

  end
end
