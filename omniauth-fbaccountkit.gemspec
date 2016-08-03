# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'omniauth/fbaccountkit/version'

Gem::Specification.new do |spec|
  s.add_dependency "omniauth",   "~> 1.2"
  s.add_dependency "faraday",   "~> 0.9"

  spec.name          = "omniauth-fbaccountkit"
  spec.version       = Omniauth::Fbaccountkit::VERSION
  spec.authors       = ["Wanderson Diego"]
  spec.email         = ["wdiego_melo@yahoo.com.br"]

  spec.summary       = %q{Facebook AccountKit Strategy for OmniAuth}
#  spec.description   = %q{TODO: Write a longer description or delete this line.}
  spec.homepage      = "https://github.com/wdiego/omniauth-fbaccountkit.git"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.12"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "byebug", "~> 9.0"

end
