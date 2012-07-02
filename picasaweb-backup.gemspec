# -*- encoding: utf-8 -*-
require File.expand_path('../lib/picasaweb-backup/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Leonard Ehrenfried"]
  gem.email    = ['leonard.ehrenfried@web.de']
  gem.summary = "Picasa Web Albums backup tool"
  gem.description = %{Backup all your photos from Google's Picasa Web Albums service,
    can be run repeatedly on the same folder and only downloads new files.}

  gem.homepage = 'http://github.com/lenniboy/picasaweb-backup'

  gem.add_dependency('gdata_19', '~> 1.1.5')

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "picasaweb-backup"
  gem.require_paths = ["lib"]
  gem.version       = Picasaweb::Backup::VERSION
end
