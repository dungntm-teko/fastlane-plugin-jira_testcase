require_relative '../options'

require 'json'
require 'json/add/exception'
require 'fastlane/action'
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
          createTest(client, params[:test_name], params[:project_key], params[:issue_key], params[:test_description] || "")
          spinner.update(title: "Create JIRA test successfully, run unit test...")

          Fastlane::Actions::ScanAction::run(
            workspace: "#{params[:workspace]}.workspace",
            scheme: params[:scheme],
            devices: params[:devices],
            only_testing: params[:whitelist_testing],
            clean: true,
            xcargs: "CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO",
          )
          spinner.update(title: "Test successfully, upload test cycle to Jira Test...")
          # Consider pass test items
          test_cases_in_issue = JSON[getTestsInIssue(client, params[:project_key], params[:issue_key])]
          items = "[{\"key\": #{test_cases_in_issue["key"]}, \"result\": #{test_cases_in_issue["result"]}}]"
          createTestCycle(client, params[:test_cycle_name], params[:project_key], params[:issue_key], params[:test_folder], items)

          spinner.success("Done")
        rescue => e
          spinner.error("Error occurs")
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
        client.post("/rest/atm/1.0/testrun", body)
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
        client.post("/rest/atm/1.0/testcase", body)
      end

      def self.getTestsInIssue(client, projectKey, issueKey)
        client.get("/rest/atm/1.0/testcase/search?query=projectKey%20=%20\"#{projectKey}\"%20AND%20issueKeys%20IN%20(#{issueKey})")
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
