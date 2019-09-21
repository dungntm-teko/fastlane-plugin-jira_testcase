require 'fastlane_core/configuration/config_item'

module Fastlane
  module JiraTestcase
    class Options
      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :url,
                      env_name: "FL_JIRA_SITE",
                      description: "URL for Jira instance",
                      optional: false),
          FastlaneCore::ConfigItem.new(key: :context_path,
                      env_name: "FL_JIRA_CONTEXT_PATH",
                      description: "Jira context path",
                      default_value: '/jira',
                      optional: true),
          FastlaneCore::ConfigItem.new(key: :username,
                      env_name: "FL_JIRA_USERNAME",
                      description: "Username for JIRA instance",
                      optional: false),
          FastlaneCore::ConfigItem.new(key: :password,
                      env_name: "FL_JIRA_PASSWORD",
                      description: "Password for Jira",
                      sensitive: true,
                      optional: false),
          FastlaneCore::ConfigItem.new(key: :project_key,
                      env_name: "FL_JIRA_PROJECT_KEY",
                      description: "Project key for Jira",
                      optional: false),
          FastlaneCore::ConfigItem.new(key: :issue_key,
                      env_name: "FL_JIRA_ISSUE_KEY",
                      description: "Issue key for Jira",
                      optional: false),
          FastlaneCore::ConfigItem.new(key: :test_cycle_name,
                      env_name: "FL_JIRA_TEST_CYCLE_NAME",
                      description: "Test cycle name",
                      optional: false),
          FastlaneCore::ConfigItem.new(key: :testcase_folder,
                      env_name: "FL_JIRA_TESTCASE_FOLDER",
                      description: "Folder that contains testcases",
                      optional: false),
          FastlaneCore::ConfigItem.new(key: :test_cycle_folder,
                      env_name: "FL_JIRA_TEST_CYCLE_FOLDER",
                      description: "Folder that contains testrun",
                      optional: false),
          FastlaneCore::ConfigItem.new(key: :workspace,
                      env_name: "FL_JIRA_WORKSPACE",
                      description: "Path to the workspace file",
                      optional: false),
          FastlaneCore::ConfigItem.new(key: :scheme,
                      env_name: "FL_JIRA_TEST_SCHEME",
                      description: "The project's scheme",
                      optional: false),
          FastlaneCore::ConfigItem.new(key: :clean,
                      env_name: "FL_JIRA_TEST_CLEAN",
                      description: "Clean build or not",
                      default_value: false,
                      optional: true),
          FastlaneCore::ConfigItem.new(key: :devices,
                      description: "Devices to run the tests on",
                      type: Array,
                      optional: false),
          FastlaneCore::ConfigItem.new(key: :whitelist_testing,
                      env_name: "FL_JIRA_WHITELIST_TESTING",
                      description: "Test Bundle/Test Suite/Test Cases to run",
                      optional: false),
        ]
      end
    end
  end
end