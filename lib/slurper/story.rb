require 'json'

module Slurper
  class Story

    attr_accessor :attributes
    def initialize(attrs={})
      self.attributes = (attrs || {}).symbolize_keys
    end

    def to_post_params
      {
        name: name,
        desc: description,
        due: nil
      }
    end

    def error_message; @response.body end

    def name;       attributes[:name]       end

    def description
      return nil unless attributes[:description].present?
      attributes[:description].split("\n").map(&:strip).join("\n")
    end

    def valid?
      if name.blank?
        raise "Name is blank for story:\n#{to_json}"
      end
    end

  end
end
