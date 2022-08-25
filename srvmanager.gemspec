# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name          = 'SrvManager'
  spec.version       = '0.0.1'
  spec.authors       = ['Joshua MARTINELLE']
  spec.email         = ['contact@jomar.fr']
  spec.summary       = 'Cloud Server Manager Library'
  spec.homepage      = ''
  spec.license       = 'MIT'
  spec.required_ruby_version = '>= 2.7.1'

  spec.files         = %w[Gemfile src/srv_manager.rb]
  spec.require_paths = ['src']
end
