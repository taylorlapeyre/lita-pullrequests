require "spec_helper"

describe Lita::Handlers::Pullrequests, lita_handler: true do
  before do
    Lita.config.handlers.pullrequests.access_token = "87084d4f3a658f2979a892b6cbf7be80b9949bcf"
    Lita.config.handlers.pullrequests.repo         = "taylorlapeyre/lita-pullrequests"
    Lita.config.handlers.pullrequests.review_label = "Needs Review"
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
    expect(replies.last).to match /Example of a pull request ready for review/
  end

  it "can respond with all pull requests" do
    send_command("summarize pull requests")
    expect(replies).to_not be_empty
    expect(replies.last).to match /Example of a pull request ready for merge/
    expect(replies.last).to match /Example of a pull request ready for review/
  end
end
