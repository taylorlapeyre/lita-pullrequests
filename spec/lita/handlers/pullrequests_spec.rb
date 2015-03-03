require "spec_helper"

describe Lita::Handlers::Pullrequests, lita_handler: true do
  before do
    Lita.config.handlers.pullrequests.access_token = "bdaf08383ca76c58ab779ab8ff1ad7f6dc5bb3a4"
    Lita.config.handlers.pullrequests.repo         = "Everlane/everlane.com"
    Lita.config.handlers.pullrequests.review_label = "Code Review"
    Lita.config.handlers.pullrequests.merge_label  = "Ready To Merge"
  end

  it { is_expected.to route_command("pull request") }
  it { is_expected.to route_command("pull request me") }
  it { is_expected.to route_command("give me something to review") }
  it { is_expected.to route_command("all pull requests") }
  it { is_expected.to route_command("summarize pull requests") }

  it "can respond with a random pull request" do
    send_command("give me something to review")
    expect(replies).to_not be_empty
  end

  it "can respond with all pull requests" do
    send_command("summarize pull requests")
    expect(replies).to_not be_empty
    puts replies.last
  end
end
