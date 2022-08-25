# frozen_string_literal: true

require_relative 'servers'

class SrvManager
  # Scaleway Class with global methods
  class Scaleway
    attr_reader :provider, :zone, :project, :api_url, :headers

    def initialize(options)
      @api_token = options[:api_token]
      @zone = options[:zone]
      @project = options[:project]
      @api_url = 'https://api.scaleway.com/'
      @headers = { 'X-Auth-Token' => @api_token, 'Content-Type' => 'application/json' }
    end

    def list
      Servers.list(self)
    end

    def create(srv_type = 'DEV1-S', image = 'ubuntu-jammy', name_pattern = 'scw-srvmanager-__RANDOM__')
      Servers.create(self, srv_type, image, name_pattern)
    end
  end
end
