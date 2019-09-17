require_relative '../options'

require 'json'
require 'json/add/exception'
require 'fastlane/action'
require 'fastlane_core'
require 'tty-spinner'

module Fastlane
  module Actions
    class JiraTestcaseAction < Action

      def self.run(params)
        Actions.verify_gem!('jira-ruby')
        require 'jira-ruby'

        options = {
          site: params[:url],
          context_path: params[:context_path],
          auth_type: :basic,
          username: params[:username],
          password: params[:password]
        }
        client = JIRA::Client.new(options)

        spinner = TTY::Spinner.new("[:spinner]", format: :dots)
        spinner.auto_spin
        spinner.update(title: "Create test on JIRA...")
        begin
          test_cases_in_issue = JSON.parse(getTestsInIssue(client, params[:project_key], params[:issue_key]))
          existed_test_cases = test_cases_in_issue.any? {|i| i['name'] == params[:test_name] }
          new_test_case = nil
          unless existed_test_cases
            new_test_case = JSON.parse(createTest(client, params[:test_name], params[:project_key], params[:issue_key], params[:test_description] || ""))
          end
          spinner.update(title: "Create JIRA test successfully, run unit test...")

          truthy = ["true", "t", "T", "on"]

          auto_pass_tests = false
          if params[:auto_pass_tests].is_a?(TrueClass)
            auto_pass_tests = true
          else
            unless params[:auto_pass_tests].is_a?(FalseClass)
              auto_pass_tests = truthy.include?(params[:auto_pass_tests])
              unless auto_pass_tests
                env_auto_pass_tests = params[:auto_pass_tests].to_i
                unless env_auto_pass_tests == 0
                  auto_pass_tests = true
                end
              end
            end
          end

          if auto_pass_tests
            spinner.update(title: "Test successfully, upload test cycle to Jira Test...")
            result_items = test_cases_in_issue.map {|i| {
              testCaseKey: i['key'],
              comment: "Outstanding pass",
              status: "Pass"
            } }
            unless new_test_case.nil?
              result_items.push({
                testCaseKey: new_test_case['key'],
                comment: "Outstanding pass",
                status: "Pass"
              })
            end
            createTestCycle(client, params[:test_cycle_name], params[:project_key], params[:issue_key], params[:test_folder], result_items)
            spinner.success("Done")
            return
          end

          clean = false
          unless params[:clean].is_a?(FalseClass)
            clean = truthy.include?(params[:clean])
            unless clean
              env_clean = params[:clean].to_i
              unless env_clean == 0
                clean = true
              end
            end
          end
          
          scan_options = FastlaneCore::Configuration.create(
            Fastlane::Actions::ScanAction.available_options,
            {
              workspace: "#{params[:workspace]}.xcworkspace",
              scheme: params[:scheme],
              devices: params[:devices],
              only_testing: params[:whitelist_testing],
              clean: clean,
              xcargs: "CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO"
            }
          )

          result_items = []

          begin
            Fastlane::Actions::ScanAction::run(scan_options)
            spinner.update(title: "Test successfully, upload test cycle to Jira Test...")
            result_items = test_cases_in_issue.map {|i| {
              testCaseKey: i['key'],
              comment: "Outstanding pass",
              status: "Pass"
            } }
            unless new_test_case.nil?
              result_items.push({
                testCaseKey: new_test_case['key'],
                comment: "Outstanding pass",
                status: "Pass"
              })
            end
            # Consider pass test items
            createTestCycle(client, params[:test_cycle_name], params[:project_key], params[:issue_key], params[:test_folder], result_items)
            spinner.success("Done")
          rescue => e
            spinner.update(title: "Test failed, upload test cycle to Jira Test...")
            result_items = test_cases_in_issue.map {|i| {
              testCaseKey: i['key'],
              comment: "Outstanding failure",
              status: "Fail"
            } }
            unless new_test_case.nil?
              result_items.push({
                testCaseKey: new_test_case['key'],
                comment: "Outstanding failure",
                status: "Fail"
              })
            end
            # Consider pass test items
            createTestCycle(client, params[:test_cycle_name], params[:project_key], params[:issue_key], params[:test_folder], result_items)
          end
        rescue => e
          spinner.error("An error occurs")
          raise e
        end
      end

      def self.createTestCycle(client, name, projectKey, issueKey, folder, items)
        body = {
          name: name,
          projectKey: projectKey,
          issueKey: issueKey,
          folder: folder,
          items: items
        }.to_json
        request = client.post("/rest/atm/1.0/testrun", body)
        request.body
      end

      def self.createTest(client, name, projectKey, issuesKey, testDesc)
        body =  {
          name: name,
          testScript: {
            type: "PLAIN_TEXT",
            text: testDesc
          },
          projectKey: projectKey,
          issueLinks: [issuesKey],
          status: "Approved"
        }.to_json
        request = client.post("/rest/atm/1.0/testcase", body)
        request.body
      end

      def self.getTestsInIssue(client, projectKey, issueKey)
        request = client.get("/rest/atm/1.0/testcase/search?query=projectKey%20=%20\"#{projectKey}\"%20AND%20issueKeys%20IN%20(#{issueKey})")
        request.body
      end

      def self.deleteTest(client, testKey)
        client.delete("/rest/atm/1.0/testcase/#{testKey}")
      end

      def self.description
        "Upload to Jira Test"
      end

      def self.authors
        ["Dũng Nguyễn"]
      end

      def self.return_value
        # If your method provides a return value, you can describe here what it does
      end

      def self.details
        # Optional:
        "Upload to Jira Test"
      end

      def self.available_options
        Fastlane::JiraTestcase::Options.available_options
      end

      def self.is_supported?(platform)
        return platform == :ios
      end
    end
  end
end
