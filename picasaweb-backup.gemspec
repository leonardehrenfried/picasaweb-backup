require File.expand_path("../lib/your_gem/version", __FILE__)

Gem::Specification.new do |gem|
  gem.name    = "picasaweb-backup"
  gem.version = "0.1"
  gem.date    = Date.today.to_s

  gem.summary = "Picasa Web Albums backup tool"
  gem.description = %{Backup all your photos from Google's Picasa Web Albums service, 
    can be run repeatedly on the same folder and only downloads new files.}

  gem.authors  = ['Leonard Ehrenfried']
  gem.email    = 'leonard.ehrenfried@web.de'
  gem.homepage = 'http://github.com/lenniboy/picasaweb-backup'

  gem.add_dependency "gdata_19", "~> 1.1.5"

  # ensure the gem is built out of versioned files
  gem.files = Dir['Rakefile', '{bin,lib,man,test,spec}/**/*', 'README*', 'LICENSE*'] & `git ls-files -z`.split("\0")
end
