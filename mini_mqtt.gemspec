#!/usr/bin/env ruby -rubygems
# -*- encoding: utf-8 -*-
#

Gem::Specification.new do |gem|
  gem.name        = 'mini_mqtt'
  gem.version     = '0.1.1'
  gem.author      = 'Armando Andini'
  gem.email       = 'armando.andini@hotmail.com'
  gem.homepage    = 'http://github.com/antico5/mini_mqtt'
  gem.summary     = 'MQTT Client for Ruby.'
  gem.description = 'Minimalist implementation of MQTT client purely in Ruby.'
  gem.license     = 'MIT'

  gem.files         = %w(README.md) + Dir.glob('lib/**/*.rb')
  gem.test_files    = Dir.glob('test/*')
  gem.executables   = %w()
  gem.require_paths = %w(lib)

  gem.add_development_dependency 'bundler',  '>= 1.0.0'
  gem.add_development_dependency 'rake',     '>= 1.0.0'
  gem.add_development_dependency 'minitest', '>= 1.0.0'
  gem.add_development_dependency 'simplecov', '>= 0.1.0'
  gem.add_development_dependency 'pry', '>= 0.1.0'
end
