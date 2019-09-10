require 'fastlane/action'

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

        spinner = TTY::Spinner.new("[:spinner] Run unit tests", format: :dots)
        spinner.auto_spin
        begin
          createTest(client, params[:test_name], params[:project_key], params[:test_description])

          Actions::Scan::run(
            workspace: params[:workspace],
            scheme: params[:scheme],
            devices: params[:devices],
            only_testing: params[:whitelist_testing],
            clean: true,
            xcargs: "CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO",
          )
          spinner.update(title: "Done testing, build a testing app now")

          Actions::Scan::run(
            workspace: params[:workspace],
            scheme: params[:scheme],
            clean: true,
            skip_detect_devices: true,
            build_for_testing: true,
            sdk: 'iphoneos',
            configuration: "Debug",
            should_zip_build_products: true
          )
          spinner.update(title: "Done building")

          JiraTestcase::IosValidator.validate_ios_app(params[:app_path])
          spinner.update(title: "Upload the testing app to Jira Test...", format: :dots)
          # Consider pass test items
          createTestCycle(client, params[:test_name], params[:project_key], params[:issue_key], params[:test_folder])

          spinner.success("Done")
        rescue => exception
          spinner.error(exception)
          raise exception
        end
      end

      def self.createTestCycle(client, name, projectKey, issueKey, folder, items = '')
        body =
            <<~END
              {
                "name": #{name},
                "projectKey": #{projectKey},
                "issueKey": #{issueKey},
                "folder": #{folder},
                "items": #{items}
              }
            END
        client.post("/rest/atm/1.0/testrun", body)
      end

      def self.createTest(client, name = '', projectKey, issuesKey, description = '')
        body =
            <<~END
              {
                "name": #{name},
                "testScript": {"type": "PLAIN_TEXT","text": "$testDescription"},
                "projectKey": #{projectKey},
                "issueLinks": [#{issuesKey}],
                "status": "Approved"
              }
            END
        client.post("/rest/atm/1.0/testcase", body)
      end

      def self.getTestsInIssue(client, projectKey, issueKey)
        client.get("/rest/atm/1.0/testcase/search?query=projectKey%20=%20\"#{projectKey}\"%20AND%20issueKeys%20IN%20(#{issueKey})")
      end

      def self.deleteTest(name = '', testKey)
        client.delete("/rest/atm/1.0/testcase/", body)
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
        [
          Fastlane::JiraTestcase::Options.available_options
        ]
      end

      def self.is_supported?(platform)
        return platform == :ios
      end
    end
  end
end
