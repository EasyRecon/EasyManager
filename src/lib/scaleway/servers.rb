# frozen_string_literal: true

require_relative 'config'
require_relative 'ips'

class SrvManager
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

        Utilities.parse_json(response.body)
      end

      def self.create(scw, srv_type, image, name_pattern)
        data = srv_data(scw, srv_type, image, name_pattern)
        return if data.nil?

        response = Typhoeus.post(File.join(scw.api_url, "/instance/v1/zones/#{scw.zone}/servers/"),
                                 headers: scw.headers, body: data.to_json)
        return unless response&.code == 201

        body_json = Utilities.parse_json(response.body)
        return unless body_json

        srv_id = body_json['server']['id']
        action(scw, srv_id, 'poweron')

        body_json
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
