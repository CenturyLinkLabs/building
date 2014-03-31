Gem::Specification.new do |s|
  s.name        = 'app2container'
  s.version     = '0.1.2'
  s.date        = '2014-03-31'
  s.summary     = "Build a Docker container for any app using Heroku Buildpacks"
  s.description = "Build a Docker container for any app using Heroku Buildpacks"
  s.authors     = ["Lucas Carlson"]
  s.email       = 'lucas@rufy.com'
  s.files       = ["lib/app2container.rb","bin/app2container"]
  s.requirements = ['bundler']
  s.homepage    = 'http://github.com/CenturyLinkLabs/app2container'
  s.license     = 'MIT'
  s.executables << 'app2container'
end
