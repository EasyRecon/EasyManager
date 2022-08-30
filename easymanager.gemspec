# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name          = 'easymanager'
  spec.version       = '0.3'
  spec.authors       = ['Joshua MARTINELLE']
  spec.email         = ['contact@jomar.fr']
  spec.summary       = 'Cloud Server Manager Library'
  spec.homepage      = ''
  spec.license       = 'MIT'
  spec.required_ruby_version = '>= 2.7.1'

  spec.add_dependency('bcrypt_pbkdf', '>= 1.1.0')
  spec.add_dependency('ed25519', '>= 1.3.0')
  spec.add_dependency('net-scp', '~> 4.0.0.rc1')
  spec.add_dependency('net-ssh', '~> 7.0.0beta1')
  spec.add_dependency('typhoeus', '>= 1.4.0')
  spec.add_dependency('x25519', '1.0.9')

  spec.files = Dir['src/**/*.rb']
end
