require 'fastlane_core/configuration/config_item'

module Fastlane
  module JiraTestcase
    class Options
      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :url,
                      env_name: "FL_JIRA_SITE",
                      description: "URL for Jira instance",
                      verify_block: proc do |value|
                        UI.user_error!("No url for Jira given, pass using `url: 'url'`") if value.to_s.length == 0
                      end),
          FastlaneCore::ConfigItem.new(key: :username,
                      env_name: "FL_JIRA_USERNAME",
                      description: "Username for JIRA instance",
                      verify_block: proc do |value|
                        UI.user_error!("No username") if value.to_s.length == 0
                      end),
          FastlaneCore::ConfigItem.new(key: :password,
                      env_name: "FL_JIRA_PASSWORD",
                      description: "Password for Jira",
                      sensitive: true,
                      verify_block: proc do |value|
                        UI.user_error!("No password") if value.to_s.length == 0
                      end),
          FastlaneCore::ConfigItem.new(key: :project_key,
                      env_name: "FL_JIRA_PROJECT_KEY",
                      description: "Project key for Jira",
                      verify_block: proc do |value|
                        UI.user_error!("No Project specified") if value.to_s.length == 0
                      end),
          FastlaneCore::ConfigItem.new(key: :issue_key,
                      env_name: "FL_JIRA_ISSUE_KEY",
                      description: "Issue key for Jira",
                      verify_block: proc do |value|
                        UI.user_error!("No Issue key specified") if value.to_s.length == 0
                      end),
          FastlaneCore::ConfigItem.new(key: :test_cycle_name,
                      env_name: "FL_JIRA_TEST_CYCLE_NAME",
                      description: "Test cycle name",
                      verify_block: proc do |value|
                        UI.user_error!("No test cycle name specified") if value.to_s.length == 0
                      end),
          FastlaneCore::ConfigItem.new(key: :test_name,
                      env_name: "FL_JIRA_TEST_NAME",
                      description: "Test name",
                      verify_block: proc do |value|
                        UI.user_error!("No test name specified") if value.to_s.length == 0
                      end),
          FastlaneCore::ConfigItem.new(key: :test_description,
                      env_name: "FL_JIRA_TEST_DESCRIPTION",
                      description: "Test description",
          FastlaneCore::ConfigItem.new(key: :test_folder,
                      env_name: "FL_JIRA_TEST_FOLDER",
                      description: "Folder that contains testrun",
                      verify_block: proc do |value|
                        UI.user_error!("No folder specified") if value.to_s.length == 0
                      end),
          FastlaneCore::ConfigItem.new(key: :test_folder,
                      env_name: "FL_JIRA_TEST_FOLDER",
                      description: "Folder that contains testrun",
                      verify_block: proc do |value|
                        UI.user_error!("No folder specified") if value.to_s.length == 0
                      end),
          FastlaneCore::ConfigItem.new(key: :workspace,
                      env_name: "FL_JIRA_WORKSPACE",
                      description: "Path to the workspace file",
                      verify_block: proc do |value|
                        UI.user_error!("No workspace specified") if value.to_s.length == 0
                      end),
          FastlaneCore::ConfigItem.new(key: :scheme,
                      env_name: "FL_JIRA_TEST_SCHEME",
                      description: "The project's scheme",
                      verify_block: proc do |value|
                        UI.user_error!("No scheme specified") if value.to_s.length == 0
                      end),
          FastlaneCore::ConfigItem.new(key: :devices,
                      env_name: "FL_JIRA_TEST_DEVICES",
                      description: "Devices to run the tests on",
                      verify_block: proc do |value|
                        UI.user_error!("No devices specified") if value.to_s.length == 0
                      end),
          FastlaneCore::ConfigItem.new(key: :whitelist_testing,
                      env_name: "FL_JIRA_WHITELIST_TESTING",
                      description: "Test Bundle/Test Suite/Test Cases to run",
                      verify_block: proc do |value|
                        UI.user_error!("No test suite specified") if value.to_s.length == 0
                      end)
        ]
      end
    end
  end
end