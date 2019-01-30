require 'bundler/setup'
Bundler.setup

require 'github_issue_maker'
require 'byebug'
require 'aws-sdk-core'
require 'aws-sdk-s3'
require 'github'
require 'github_api'

RSpec.configure do |config|
  # some (optional) config here
end