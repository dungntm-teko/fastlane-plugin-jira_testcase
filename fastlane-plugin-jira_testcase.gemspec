
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fastlane/plugin/jira_testcase/module'

Gem::Specification.new do |spec|
  spec.name          = Fastlane::JiraTestcase::PLUGIN_NAME
  spec.version       = Fastlane::JiraTestcase::VERSION
  spec.author        = 'Dũng Nguyễn'
  spec.email         = 'dung.ntm1@teko.vn'

  spec.summary       = 'Run unit testing and upload to Jira Test'
  spec.homepage      = "https://github.com/dungntm-teko/fastlane-plugin-jira_testcase"
  spec.license       = "MIT"

  spec.files         = Dir["lib/**/*"] + %w(README.md LICENSE)
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency('jira-ruby')
  spec.add_dependency('tty-spinner', '>= 0.8.0', '< 1.0.0')

  spec.add_development_dependency('pry')
  spec.add_development_dependency('bundler')
  spec.add_development_dependency('rspec')
  spec.add_development_dependency('rspec_junit_formatter')
  spec.add_development_dependency('rake')
  spec.add_development_dependency('rubocop', '0.49.1')
  spec.add_development_dependency('rubocop-require_tools')
  spec.add_development_dependency('simplecov')
  spec.add_development_dependency('fastlane', '>= 2.129.0')
end
