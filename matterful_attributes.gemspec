# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'matterful_attributes/version'

Gem::Specification.new do |spec|
  spec.name          = "matterful_attributes"
  spec.version       = MatterfulAttributes::VERSION
  spec.authors       = ["Nick Gorbikoff"]
  spec.email         = ["nick.gorbikoff@gmail.com"]
  spec.description   = %q{Ruby / Rails gem that shims ActiveRecord::Base to provide some helpful methods for parsing out attributes that matter to humans, i.e. Address.first.matterful_attributes will return a hash of attributes minus id, type, polymorphic_id, polymorphic_type, cretated_at, updated_at and can also skip all foreign_keys, like category_id or status_id. }
  spec.summary       = %q{See Readme.md}
  spec.homepage      = "https://github.com/konung/matterful_attributes"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
