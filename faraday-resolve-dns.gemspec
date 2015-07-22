Gem::Specification.new do |spec|
  spec.add_dependency 'faraday', '~>0.9.0'
  spec.add_development_dependency 'bundler', '~> 1.0'
  spec.authors = ["Alex Ianus"]
  spec.description = %q{Resolve DNS before passing request through to proxy}
  spec.email = ['hire@alexianus.com']
  spec.files = %w(LICENSE README.md faraday-resolve-dns.gemspec)
  spec.files += Dir.glob("lib/**/*.rb")
  spec.files += Dir.glob("spec/**/*")
  spec.homepage = 'https://github.com/aianus/faraday-resolve-dns'
  spec.licenses = ['MIT']
  spec.name = 'faraday-resolve-dns'
  spec.require_paths = ['lib']
  spec.required_rubygems_version = '>= 1.3.5'
  spec.summary = spec.description
  spec.test_files += Dir.glob("spec/**/*")
  spec.version = '0.0.1'
end
