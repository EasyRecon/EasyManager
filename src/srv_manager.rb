# frozen_string_literal: true

require 'typhoeus'

require_relative 'lib/scaleway/main'
require_relative 'lib/utilities'

# DEBUG DEV
options = {
  zone: 'fr-par-1',
  project: '',
  api_token: ''
}

manager = SrvManager::Scaleway.new(options)
p manager.list
# p manager.create
