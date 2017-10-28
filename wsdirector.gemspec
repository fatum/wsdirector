
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "wsdirector/version"

Gem::Specification.new do |spec|
  spec.name          = "wsdirector"
  spec.version       = Wsdirector::VERSION
  spec.authors       = ["Maxim Filippovich"]
  spec.email         = ["fatumka@gmail.com"]

  spec.summary       = %q{Websocket scenarios runner}
  spec.description   = %q{This library lets running test scenarios for websocket service}
  spec.homepage      = "TODO: Put your gem's website or public repo URL here."

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "dry-configurable", "0.7.0"
  spec.add_dependency "concurrent-ruby", "1.0.5"
  spec.add_dependency "concurrent-ruby-ext", "1.0.5"
  spec.add_dependency "concurrent-ruby-edge", "0.3.1"
  spec.add_dependency "websocket-client-simple", "0.3.0"

  spec.add_development_dependency "pry"
  spec.add_development_dependency "puma"
  spec.add_development_dependency "litecable"
  spec.add_development_dependency "bundler", "~> 1.16.a"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
