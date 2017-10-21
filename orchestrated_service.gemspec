# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'orchestrated_service/version'

Gem::Specification.new do |spec|
  spec.name          = "orchestrated_service"
  spec.version       = OrchestratedService::VERSION
  spec.authors       = ["Ollie"]
  spec.email         = ["ollie.hm@cantab.net"]

  spec.summary       = "Simply and neatly orchestrate the steps your controllers - or in fact anything else - carry out."
  spec.description   = <<-EOF
      Gives your service objects a straightforward steps method for listing steps,
      carrying them out, using previous steps, nesting steps and handling failures
      - so your code just has to implement each step, not worry about orchestrating them.
      You can further separate the orchestration logic by putting the implementation for
      a step somewhere entirely separate and reusable, in another service object (that could
      itself use the steps method to orchestrate its tasks!)
    EOF
  spec.homepage      = "https://github.com/ollieh-m/orchestrated-service"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
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

  spec.add_dependency "activerecord"
  spec.add_development_dependency "bundler", "~> 1.14"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
