# frozen_string_literal: true

class EasyManager
  class Scaleway
    # Specific method for ips management
    # https://developers.scaleway.com/en/products/instance/api/#ips-268151
    class Ips
      def self.reserve(scw)
        data = { project: scw.project }

        response = Typhoeus.post(
          File.join(scw.api_url, "instance/v1/zones/#{scw.zone}/ips"),
          headers: scw.headers,
          body: data.to_json
        )
        return unless response&.code == 201

        Utilities.parse_json(response.body)
      end

      def self.delete(scw, ip_id, tries = 0)
        resp = Typhoeus.delete(
          File.join(scw.api_url, "/instance/v1/zones/#{scw.zone}/ips/#{ip_id}"),
          headers: scw.headers
        )
        return resp if resp&.code == 204

        sleep(rand(10..60))
        tries += 1
        delete(scw, ip_id, tries) unless tries >= 3
      end
    end
  end
end
