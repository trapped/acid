Gem::Specification.new do |gem|
  gem.name      = 'acid'
  gem.version   = '0.1'

  gem.author    = 'C453'
  gem.homepage  = 'https://github.com/C453/acid'
  gem.summary   = 'Easy and simple Continuous Integration'
  gem.license   = 'MIT'

  gem.files     = %x{ git ls-files }.split("\n").select { |d| d =~ %r{^(LICENSE|README|bin/|lib/)} }

  gem.add_dependency 'colorize'
end
