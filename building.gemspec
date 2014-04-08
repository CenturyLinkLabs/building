Gem::Specification.new do |s|
  s.name        = 'building'
  s.version     = '1.1.2'
  s.date        = '2014-03-31'
  s.summary     = "Build a Docker container for any app using Heroku Buildpacks"
  s.description = "Build a Docker container for any app using Heroku Buildpacks"
  s.authors     = ["Lucas Carlson"]
  s.email       = 'lucas@rufy.com'
  s.files       = ["lib/building.rb","bin/building"]
  s.requirements = ['bundler', 'highline']
  s.homepage    = 'http://github.com/CenturyLinkLabs/building'
  s.license     = 'MIT'
  s.executables = ['building']
end
