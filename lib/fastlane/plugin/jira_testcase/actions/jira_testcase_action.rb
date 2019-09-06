require 'fastlane/action'

module Fastlane
  module Actions
    class JiraTestcaseAction < Action
      DEFAULT_APP_BUNDLE_NAME = "bundle"
      PULL_RESULT_INTERVAL = 5

      RUNNING_STATES = %w(VALIDATING PENDING RUNNING)

      private_constant :DEFAULT_APP_BUNDLE_NAME
      private_constant :PULL_RESULT_INTERVAL
      private_constant :RUNNING_STATES

      def self.run(params)
        Actions.verify_gem!('jira-ruby')
        require 'jira-ruby'

        site         = params[:url]
        auth_type    = :basic
        username     = params[:username]
        password     = params[:password]
        ticket_id    = params[:ticket_id]
        comment_text = params[:comment_text]
        app_path     = params[:app_path]

        JiraTestcase::IosValidator.validate_ios_app(app_path)
        upload_spinner = TTY::Spinner.new("[:spinner] Uploading the app to Jira Test...", format: :dots)
        upload_spinner.auto_spin
        options = {
            site: site,
            context_path: context_path,
            auth_type: auth_type,
            username: username,
            password: password
        }
        client = JIRA::Client.new(options)


        upload_spinner.success("Done")

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

      def self.createTest(name = '', projectKey, issuesKey, description = '')
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
