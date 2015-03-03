require "spec_helper"

describe Lita::Handlers::Pullrequests, lita_handler: true do
  before do
    Lita.config.handlers.pullrequests.access_token = ENV["GITHUB_ACCESS_TOKEN"]
    Lita.config.handlers.pullrequests.repo         = "taylorlapeyre/lita-pullrequests"
    Lita.config.handlers.pullrequests.review_label = "Needs Review"
    Lita.config.handlers.pullrequests.merge_label  = "Ready To Merge"
  end

  it { is_expected.to route_command("pull request").to(:get_random_pr) }
  it { is_expected.to route_command("pull request me").to(:get_random_pr) }
  it { is_expected.to route_command("give me something to review").to(:get_random_pr) }
  it { is_expected.to route_command("all pull requests").to(:list_all_pull_requests) }
  it { is_expected.to route_command("summarize pull requests").to(:list_all_pull_requests) }

  it { is_expected.to_not route_command("all pull requests").to(:get_random_pr) }

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
