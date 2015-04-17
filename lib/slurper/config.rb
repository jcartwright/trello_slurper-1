module Slurper

  class Config

    def self.trello_application_key; @trello_application_key ||= yaml['trello_application_key'] end
    def self.trello_board_id; @trello_board_id ||= yaml['trello_board_id'] end
    def self.trello_write_token; @trello_write_token ||= yaml['trello_write_token'] end

    def self.valid?
      !trello_application_key.blank? &&
      !trello_board_id.blank? &&
      !trello_write_token.blank?
    end

    def self.errors
      [].tap do |errors|
        errors << ":trello_application_key is required" if trello_application_key.blank?
        errors << ":trello_board_id is required" if trello_board_id.blank?
        errors << ":trello_write_token is required" if trello_write_token.blank?
      end
    end

    def self.to_s
      yaml.to_s
    end

    def self.store(key, value)
      yaml[key.to_s] = value.to_s
      File.open("tslurper_config.yml", 'w') { |f| YAML.dump(yaml, f) }
    end

    private

    def self.yaml
      @yaml ||= YAML.load_file('tslurper_config.yml')
    end

  end

end
