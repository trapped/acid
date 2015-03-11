Gem::Specification.new do |gem|
  gem.name        = 'acid'
  gem.version     = '0.2'

  gem.author      = 'trapped'
  gem.email	  = 'giorgio@pellero.it'
  gem.homepage    = 'https://github.com/trapped/acid'
  gem.description = 'Simple build worker that reads a YAML configuration file and runs a list of commands.'
  gem.summary     = 'Easy and simple Continuous Integration'
  gem.license     = 'MIT'

  gem.files       = %x{ git ls-files }.split("\n").select { |d| d =~ %r{^(LICENSE|README|bin/|lib/)} }

  gem.add_dependency 'colorize', '~> 0'
  gem.add_dependency 'pry', '~> 0'
end
