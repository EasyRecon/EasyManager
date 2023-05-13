# frozen_string_literal: true

class EasyManager
  class Scaleway
    # Methods to retrieve information specific to Scaleway
    class Config
      def self.srv_infos(srv_type)
        srv_infos = {
          'DEV1-S' => { volume: 20_000_000_000, volume_type: 'b_ssd' },
          'DEV1-M' => { volume: 40_000_000_000, volume_type: 'b_ssd' },
          'DEV1-L' => { volume: 80_000_000_000, volume_type: 'b_ssd' },
          'DEV1-XL' => { volume: 120_000_000_000, volume_type: 'b_ssd' }
        }
        srv_infos[srv_type]
      end

      def self.image_id(image)
        image_id = {
          'ubuntu-jammy' => '2289fad9-2694-48ab-bb41-f19e4a9a8584',
          'debian-buster' => '6d124a42-de28-493f-933b-85a0df5552eb'
        }
        image_id[image]
      end
    end
  end
end
