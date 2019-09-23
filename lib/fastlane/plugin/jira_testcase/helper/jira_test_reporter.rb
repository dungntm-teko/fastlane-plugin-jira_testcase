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
        @client = JIRA::Client.new(options)
      end

      def run
        result_items = []

        xctestresult_path = self.xctestresult_path
        if xctestresult_path.nil?
          return
        end

        info = Plist.parse_xml("#{xctestresult_path}/TestSummaries.plist")

        # test_cases_in_issue = JSON.parse(get_tests_in_issue)

        # existed_test_cases = test_cases_in_issue.any? {|i| i['name'] == test_name }
        # new_test_case = nil
        # unless existed_test_cases
        #   new_test_case = JSON.parse(request_create_test(test_name, test_description || ""))
        # end

        # result_items = test_cases_in_issue.map {|i| {
        #   testCaseKey: i['key'],
        #   comment: "Outstanding pass",
        #   status: "Pass"
        # } }
        # unless new_test_case.nil?
        #   result_items.push({
        #     testCaseKey: new_test_case['key'],
        #     comment: "Outstanding pass",
        #     status: "Pass"
        #   })
        # end
        # Consider pass test items
        # request_create_test_cycle(result_items)
      end

      def delete_test(test_key)
        @client.delete("/rest/atm/1.0/testcase/#{test_key}")
      end

      private

      def xctestresult_path
        project = FastlaneCore::Project(workspace: @workspace, scheme: @scheme)
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