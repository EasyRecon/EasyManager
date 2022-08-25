# frozen_string_literal: true

require 'json'

# Utility method that can be reused in the code
class Utilities
  def self.parse_json(content)
    JSON.parse(content)
  rescue JSON::ParseError
    nil
  end

  def self.random_string
    (0...8).map { rand(97..122).chr }.join
  end
end
