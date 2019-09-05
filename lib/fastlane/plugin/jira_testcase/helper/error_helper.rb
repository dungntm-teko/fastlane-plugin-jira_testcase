require 'json'

module Fastlane
  module JiraTestcase
    class ErrorHelper
      def self.summarize_jira_error(payload)
        begin
          response = JSON.parse(payload)
        rescue JSON::ParserError => ex
          FastlaneCore::UI.error("Unable to parse error message: #{ex.class}, message: #{ex.message}")
          return payload
        end

        if response["error"]
          return "#{response['error']['message']}\n#{payload}"
        end
        return payload
      end
    end
  end
end
