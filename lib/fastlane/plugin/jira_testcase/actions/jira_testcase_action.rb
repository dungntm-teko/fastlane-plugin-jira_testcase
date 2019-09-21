require_relative '../options'
require_relative '../helper/jira_test_reporter'

require 'fastlane/action'
require 'fastlane_core'
require 'tty-spinner'

module Fastlane
  module Actions
    class JiraTestcaseAction < Action

      def self.run(params)
        spinner = TTY::Spinner.new("[:spinner]", format: :dots)
        spinner.auto_spin
        spinner.update(title: "Run unit test...")

        truthy = ["true", "t", "T", "on"]

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

        begin
          Fastlane::Actions::ScanAction::run(scan_options)
        rescue => e
        end

        spinner.update(title: "Run test successfully. Upload test cycle to Jira Test...")
        reporter = Fastlane::JiraTestcase::JiraTestReporter(params)
        reporter.run

        spinner.success("Done")
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
