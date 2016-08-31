Gem::Specification.new do |spec|
  spec.name          = 'lita-zendesk'
  spec.date          = '2016-08-31'
  spec.version       = '0.0.5'
  spec.authors       = ['John Wang']
  spec.email         = ['johncwang@gmail.com']
  spec.description   = %q{A Zendesk handler for Lita.}
  spec.summary       = %q{A Zendesk handler for the Lita chatbot.}
  spec.homepage      = 'https://github.com/grokify/lita-zendesk'
  spec.license       = 'MIT'
  spec.metadata      = { 'lita_plugin_type' => 'handler' }

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'faraday', '~> 0.9', '>= 0.9'
  spec.add_runtime_dependency 'faraday_middleware', '~> 0', '>= 0'
  spec.add_runtime_dependency 'lita', '>= 4.4.3'

  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'pry-byebug'
  spec.add_development_dependency 'rack-test'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec', '>= 3.0.0'
  spec.add_development_dependency 'simplecov', '>= 0.9.2'
  spec.add_development_dependency 'coveralls'
end
