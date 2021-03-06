# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rubygems'
require 'css_compare/constants'

CSSCOMPARE_GEMSPEC = Gem::Specification.new do |spec|
  spec.name          = 'css_compare'
  spec.version       = CssCompare::VERSION
  spec.authors       = ['Attila Večerek']
  spec.email         = ['attila.vecerek@gmail.com']

  spec.summary       = 'AST-based CSS comparing tool.'
  spec.description   = <<-END
      Processes, evaluates and compares 2 different
      CSS files based on their AST.
  END
  spec.homepage      = 'https://github.com/vecerek/css-compare'
  spec.license       = 'MIT'

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  if spec.respond_to?(:metadata)
    # spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise 'RubyGems 2.0 or newer is required to protect against public gem pushes.'
  end

  readmes = Dir['*'].reject { |x| x =~ /(^|[^.a-z])[a-z]+/ || x == 'TODO' }
  spec.executables   = %w(css_compare)
  spec.files         = Dir['lib/**/*', 'bin/*', 'Rakefile'] + readmes
  spec.test_files    = Dir['spec/lib/**/*_spec.rb', 'test/**/*_test.rb']
  spec.has_rdoc      = false
  spec.require_paths = ['lib']

  spec.add_dependency 'sass', '~> 3.4'
  spec.add_dependency 'color', '~> 1.8'

  spec.add_development_dependency 'rake', '~> 11.1'
  spec.add_development_dependency 'rspec', '~> 3.0'
end
