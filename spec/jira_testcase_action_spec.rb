describe Fastlane::Actions::JiraTestcaseAction do
  describe '#run' do
    it 'prints a message' do
      expect(Fastlane::UI).to receive(:message).with("The jira_testcase plugin is working!")

      Fastlane::Actions::JiraTestcaseAction.run(nil)
    end
  end
end
