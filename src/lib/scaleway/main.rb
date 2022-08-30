# frozen_string_literal: true

require 'date'
require_relative 'servers'
require_relative '../ssh'

class EasyManager
  # Scaleway Class with global methods
  class Scaleway
    attr_reader :provider, :zone, :project, :api_url, :headers, :secret_token

    def initialize(options)
      @secret_token = options[:secret_token]
      @zone = options[:zone]
      @project = options[:project]
      @api_url = 'https://api.scaleway.com/'
      @headers = { 'X-Auth-Token' => @secret_token, 'Content-Type' => 'application/json' }
    end

    def list
      Servers.list(self)
    end

    def create(options)
      srv_type = options[:srv_type] || 'DEV1-S'
      image = options[:image] || 'ubuntu-jammy'
      name_pattern = options[:name_pattern] || 'scw-easymanager-__RANDOM__'
      cloud_init = options[:cloud_init] || false

      Servers.create(self, srv_type, image, name_pattern, cloud_init)
    end

    def delete(srv)
      Servers.delete(self, srv['id'], srv['public_ip']['id'])
    end

    def delete_by_id(id)
      servers = list

      servers.each { |server| delete(server) if server['id'] == id }
    end

    def status(srv)
      Servers.status(self, srv['id'])
    end

    def srv_ready?(srv, ssh)
      Servers.ready?(self, srv, ssh, srv_ready_cmds)
    end

    def wait_until_ready!(srv, ssh, timeout = 300)
      ready = false
      start = Time.now
      loop do
        ready = srv_ready?(srv, ssh)
        break if ready || Utilities.elapsed_times(Time.now.to_s, start.to_s) >= timeout

        sleep(30)
      end

      ready
    end

    private

    def srv_ready_cmds
      check_cloud_init_cmd = "test -f '/var/log/cloud-init.log' && echo true"
      cloud_init_ready_cmd = 'tail -1 /var/log/cloud-init-output.log'

      [check_cloud_init_cmd, cloud_init_ready_cmd, 'hostname']
    end
  end
end
