require "spec_helper"

describe Lita::Handlers::Pullrequests, lita_handler: true do
  before do
    Lita.config.handlers.pullrequests.access_token = ENV["GITHUB_ACCESS_TOKEN"]
    Lita.config.handlers.pullrequests.repos        = ["taylorlapeyre/lita-pullrequests"]
    Lita.config.handlers.pullrequests.review_label = "Needs Review"
    Lita.config.handlers.pullrequests.merge_label  = "Ready To Merge"
    Lita.config.handlers.pullrequests.qa_label     = "QA Needed"
  end

  it { is_expected.to route_command("give me something to review for lita-pullrequests").to(:get_random_pr) }
  it { is_expected.to route_command("all pull requests").to(:list_all_pull_requests) }
  it { is_expected.to route_command("summarize pull requests").to(:list_all_pull_requests) }
  it { is_expected.to route_command("set pull requests reminder for 0 20 * * 1-5").to(:set_reminder) }
  it { is_expected.to route_command("set pull request reminder for 0 20 * * 1-5").to(:set_reminder) }
  it { is_expected.to route_command("stop reminding me about pull requests").to(:remove_reminder) }
  it { is_expected.to route_command("show pull requests reminder").to(:show_reminder) }
  it { is_expected.to route_command("show pull request reminder").to(:show_reminder) }

  it { is_expected.to_not route_command("all pull requests").to(:get_random_pr) }

  it "can respond with a random pull request" do
    send_command("give me something to review for lita-pullrequests")
    expect(replies).to_not be_empty
    expect(replies.last).to match /Example of a pull request ready for review/
  end

  it "knows when you asked for a repo that it doesn't know about." do
    send_command("give me something to review for foobar")
    expect(replies).to_not be_empty
    expect(replies.last).to eq "I'm not configured for a repo with that name."
  end

  it "can respond with all pull requests" do
    send_command("summarize pull requests")
    expect(replies).to_not be_empty
    expect(replies.last).to match /Example of a pull request ready for merge/
    expect(replies.last).to match /Example of a pull request ready for review/
  end

  it "can schedule a reminder" do
    send_command("set pull requests reminder for 0 20 * * 1-5")
    expect(replies.last).to match /0 20 \* \* 1\-5/
  end

  it "can stop reminding you" do
    send_command("set pull requests reminder for 0 20 * * 1-5")
    expect(replies.last).to match /0 20 \* \* 1\-5/
    send_command("stop reminding me about pull requests")
    expect(replies.last).to eq "okay, I turned off your reminder."
  end

  it "can tell you when it will remind you next" do
    send_command("set pull requests reminder for 0 20 * * 1-5")
    expect(replies.last).to match /0 20 \* \* 1\-5/
    send_command("show pull requests reminder")
    expect(replies.last).to match /I will remind you/
  end
end
