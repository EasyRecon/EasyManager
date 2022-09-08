# frozen_string_literal: true

require_relative 'config'
require_relative 'ips'

class EasyManager
  class Scaleway
    # Specific method for server management
    # https://developers.scaleway.com/en/products/instance/api/#servers-8bf7d7
    class Servers
      def self.list(scw)
        response = Typhoeus.get(
          File.join(scw.api_url, "instance/v1/zones/#{scw.zone}/servers"),
          headers: scw.headers
        )
        return unless response&.code == 200

        json_body = Utilities.parse_json(response.body)
        return unless json_body

        json_body['servers']
      end

      def self.srv_up?(scw, srv)
        status(scw, srv['id']) == 'running' && Utilities.elapsed_times(Time.now.to_s, srv['creation_date']) > 90
      end

      def self.ready?(scw, srv, ssh, cmds)
        return unless srv_up?(scw, srv)

        cmd_values = SSH.cmd_exec(ssh, srv, cmds)
        return unless cmd_values
        return if cmd_values[cmds[0]].empty?

        cmd_values[cmds[1]].include?('The system is finally up') ||
          cmd_values[cmds[1]].match?(/Cloud-init v.*finished\sat.*Up.*seconds/)
      end

      def self.status(scw, srv_id)
        response = Typhoeus.get(
          File.join(scw.api_url, "/instance/v1/zones/#{scw.zone}/servers/#{srv_id}"),
          headers: scw.headers
        )
        return unless response&.code == 200

        json_body = Utilities.parse_json(response.body)
        return unless json_body

        json_body['server']['state']
      end

      def self.create(scw, srv_type, image, name_pattern, cloud_init)
        data = srv_data(scw, srv_type, image, name_pattern)
        return if data.nil?

        response = Typhoeus.post(File.join(scw.api_url, "/instance/v1/zones/#{scw.zone}/servers/"),
                                 headers: scw.headers, body: data.to_json)
        return unless response&.code == 201

        body_json = Utilities.parse_json(response.body)
        return unless body_json

        srv_id = body_json['server']['id']
        launch(scw, srv_id, cloud_init)

        body_json['server']
      end

      def self.delete(scw, srv_id, srv_ip_id)
        Ips.delete(scw, srv_ip_id)
        action(scw, srv_id, 'terminate')
      end

      def self.launch(scw, srv_id, cloud_init)
        add_cloud_init(scw, srv_id, cloud_init) if cloud_init
        action(scw, srv_id, 'poweron')
      end

      def self.add_cloud_init(scw, srv_id, cloud_init)
        data = Utilities.file_read(cloud_init)
        return if data.nil?

        Typhoeus.patch(
          File.join(scw.api_url, "/instance/v1/zones/#{scw.zone}/servers/#{srv_id}/user_data/cloud-init"),
          headers: { 'X-Auth-Token' => scw.secret_token, 'Content-Type' => 'text/plain' },
          body: data
        )
      end

      def self.action(scw, srv_id, action)
        data = { action: action }
        Typhoeus.post(
          File.join(scw.api_url, "/instance/v1/zones/#{scw.zone}/servers/#{srv_id}/action"),
          headers: scw.headers,
          body: data.to_json
        )
      end

      def self.srv_data(scw, srv_type, image, name_pattern)
        srv_infos = Config.srv_infos(srv_type)
        image_id = Config.image_id(image)
        new_ip = Ips.reserve(scw)
        return if image_id.nil? || srv_infos.nil? || new_ip.nil?

        {
          name: name_pattern.gsub('__RANDOM__', Utilities.random_string), commercial_type: srv_type,
          public_ip: new_ip['ip']['id'], project: scw.project,
          image: image_id,
          volumes: { '0' => { size: srv_infos[:volume], volume_type: srv_infos[:volume_type] } }
        }
      end
    end
  end
end
