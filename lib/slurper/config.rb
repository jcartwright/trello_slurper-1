module Slurper

  class Config

    def self.trello_application_key; @trello_application_key ||= yaml['trello_application_key'] end
    def self.trello_board_id; @trello_board_id ||= yaml['trello_board_id'] end
    def self.trello_write_token; @trello_write_token ||= yaml['trello_write_token'] end

    private

    def self.yaml
      YAML.load_file('tslurper_config.yml')
    end

  end

end
