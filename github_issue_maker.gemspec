Gem::Specification.new do |s|
  s.name        = 'github_issue_maker'
  s.version     = '0.0.2'
  s.date        = '2018-12-13'
  s.summary     = 'Creates GitHub Issues from a UserIssue model'
  s.description = 'A GitHub Issue creation gem'
  s.authors     = ['Jared Loucks']
  s.email       = 'jaredbrianming@gmail.com'
  s.files       = ['lib/github_issue_maker.rb']
  s.homepage    = 'http://rubygems.org/gems/github_issue_maker'
  s.license     = 'MIT'
  s.add_dependency 'aws-sdk-core'
  s.add_dependency 'aws-sdk-s3'
  s.add_dependency 'github'
  s.add_dependency 'github_api'
  s.add_development_dependency 'rspec'
end