Gem::Specification.new do |spec|
  spec.name          = "lita-pullrequests"
  spec.version       = "0.0.4"
  spec.authors       = ["Taylor Lapeyre"]
  spec.email         = ["taylorlapeyre@gmail.com"]
  spec.description   = %q{A Lita handler to help you keep track of your pull requests.}
  spec.summary       = %q{A Lita handler to help you keep track of your pull requests.}
  spec.homepage      = "https://github.com/taylorlapeyre/lita-pullrequests"
  spec.license       = "MIT"
  spec.metadata      = { "lita_plugin_type" => "handler" }

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "lita", ">= 4.1"
  spec.add_runtime_dependency "rufus-scheduler"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rack-test"
  spec.add_development_dependency "rspec", ">= 3.0.0"
end
