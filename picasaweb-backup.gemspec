# -*- encoding: utf-8 -*-
require File.expand_path('../lib/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Leonard Ehrenfried"]
  gem.email    = ['leonard.ehrenfried@gmail.com']
  gem.summary = "Picasa Web Albums backup tool"
  gem.description = %{Backup all your photos from Google's Picasa Web Albums service,
    can be run repeatedly on the same folder and only downloads new files.}

  gem.homepage = 'http://github.com/leonardehrenfried/picasaweb-backup'

  gem.add_dependency('artii',       '~> 2.1')
  gem.add_dependency('colored',     '~> 1.2')
  gem.add_dependency('googleauth',  '~> 0.5.1')
  gem.add_dependency('http',        '~> 2.1')

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "picasaweb-backup"
  gem.require_paths = ["lib"]
  gem.version       = Picasaweb::Backup::VERSION
end
