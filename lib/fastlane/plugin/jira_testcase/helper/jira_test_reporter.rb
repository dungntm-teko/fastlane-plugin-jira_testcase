require 'jira-ruby'
require 'json'
require 'plist'

require 'fastlane_core/project'

module Fastlane
  module JiraTestcase
    class JiraTestReporter
      def initialize(params)
        options = {
          site: params[:url],
          context_path: params[:context_path],
          auth_type: :basic,
          username: params[:username],
          password: params[:password]
        }
        @project_key = params[:project_key]
        @issue_key = params[:issue_key]
        @test_cycle_name = params[:test_cycle_name]
        @test_cycle_folder = params[:test_cycle_folder]
        @test_case_folder = params[:test_case_folder]
        @workspace = params[:workspace]
        @scheme = params[:scheme]

        @project = FastlaneCore::Project(workspace: @workspace, scheme: @scheme)
        @client = JIRA::Client.new(options)
      end

      def run
        jira_test_case_items = []
        result_items = []

        xctestresult_path = self.xctestresult_path
        if xctestresult_path.nil?
          return
        end

        xcode_version = @project.default_build_settings(key: 'XCODE_VERSION_ACTUAL').to_i
        if xcode_version >= 1100 # xcode 11 or higher
          result_items = self.retrieve_results_xcode_11
        elsif xcode_version >= 1000
          result_items = self.retrieve_results_xcode_10
        end

        test_cases_in_issue = JSON.parse(get_tests_in_issue)

        result_items.each do |item|

          # TODO: Build true object
          test_name = item['name']
          test_description = item['description'] || ""
          status = item['result'] == 'Success' ? 'Pass' : 'Fail'

          existed_test_cases = test_cases_in_issue.select? {|i| i['name'] == test_name}

          if existed_test_cases.empty?
            new_test_case = JSON.parse(request_create_test(test_name, test_description))
            jira_test_case_items.push({
              testCaseKey: new_test_case['key'],
              comment: "Outstanding #{status}",
              status: status
            })
          else
            jira_test_case_items.concat(existed_test_cases.map {|i| {
              testCaseKey: i['key'],
              comment: "Outstanding #{status}",
              status: status
            } })
          end
        end

        # Consider pass test items
        request_create_test_cycle(jira_test_case_items)
      end

      def delete_test(test_key)
        @client.delete("/rest/atm/1.0/testcase/#{test_key}")
      end

      private

      def retrieve_results_xcode_11(xctestresult_path)
        result_string = %x|xcrun xcresulttool get --format json --path #{xctestresult_path}|
        summary_result_json = JSON.parse(result_string)
        summary_id = result_json['actions']['_values'][0]['actionResult']['testsRef']['id']['_value']

        result_string = %x|xcrun xcresulttool get --format json --path #{xctestresult_path} --id #{summary_id}|
        result_json = JSON.parse(result_string)
        test_cases_json = result_json['summaries']['_values'][0]['testableSummaries']['_values'][0]['tests']['_values']
        test_cases_json.map { |json| {
          {
            'name': json['name']['_value']
            
          }
        } }
      end

      def retrieve_results_xcode_10(xctestresult_path)
        test_summaries = Plist.parse_xml("#{xctestresult_path}/TestSummaries.plist")

      end

      def xctestresult_path
        build_dir = nil
        begin
          build_dir = File.dirname(project.default_build_settings(key: 'BUILD_DIR'))
        rescue => e
          return nil
        end

        if build_dir.nil?
          return nil
        end
        
        derived_data_path = File.expand_path('..', build_dir)
        test_logs_path = "#{derived_data_path}/Logs/Test"
        log_manifest = Plist.parse_xml("#{test_logs_path}/LogStoreManifest.plist")
        logs = log_manifest['logs']

        xctestrun_file_name = nil
        logs.each_value do |log|
          test_scheme = log['schemeIdentifier-schemeName']
          if test_scheme == @scheme
            xctestrun_file_name = log['fileName']
            break
          end
        end
        if xctestrun_file_name.nil?
          return nil
        end
        return "#{test_logs_path}/#{xctestrun_file_name}"
      end

      def request_create_test_cycle(items)
        body = {
          name: @test_cycle_name,
          projectKey: @project_key,
          issueKey: @issue_key,
          folder: @test_cycle_folder,
          items: items
        }.to_json
        request = @client.post("/rest/atm/1.0/testrun", body)
        request.body
      end

      def request_create_test(name, test_desc)
        body =  {
          name: name,
          testScript: {
            type: "PLAIN_TEXT",
            text: test_desc
          },
          projectKey: @project_key,
          folder: @test_case_folder,
          issueLinks: [@issue_key],
          status: "Approved"
        }.to_json
        request = @client.post("/rest/atm/1.0/testcase", body)
        request.body
      end

      def get_tests_in_issue
        request = @client.get("/rest/atm/1.0/testcase/search?query=projectKey%20=%20\"#{@project_key}\"%20AND%20issueKeys%20IN%20(#{@issue_key})%20AND%20folder=\"#{@test_case_folder}\"")
        request.body
      end
    end
  end
end