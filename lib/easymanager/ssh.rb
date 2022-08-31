# frozen_string_literal: true

require 'net/ssh'
require 'net/scp'

class EasyManager
  # SSH Class
  class SSH
    attr_reader :username, :ssh_key

    def initialize(options = {})
      @username = options[:username] || 'root'
      @ssh_key = options[:ssh_key] || '/root/.ssh/id_rsa'
    end

    def self.cmd_exec(ssh, srv, cmds)
      cmd_values = {}

      Net::SSH.start(srv['public_ip']['address'], ssh.username, keys: ssh.ssh_key) do |shell|
        cmds.each do |cmd|
          cmd_values[cmd] = shell.exec!(cmd).chomp
        end
      end

      cmd_values
    rescue Net::SSH::AuthenticationFailed
      nil
    end

    def self.scp(ssh, srv, files)
      Net::SCP.start(srv['public_ip']['address'], ssh.username, keys: ssh.ssh_key) do |shell|
        files.each do |name, infos|
          shell.upload! name, infos[:remote], recursive: infos[:recursive] || false
        end
      end
    rescue Net::SSH::AuthenticationFailed
      nil
    end
  end
end
