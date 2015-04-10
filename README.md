# lita-pullrequests

A Lita handler to help you **keep track of your pull requests**. It can automatically post in your channels on a schedule and tell you about pull requests that need attention in all of your repositories.

1. Organize pull requests with labels on GitHub
2. Lita will remind you about them later

## Installation

Add lita-pullrequests to your Lita instance's Gemfile:

``` ruby
gem "lita-pullrequests"
```

## Configuration

Pull request summaries include three sections:

1. :heavy_exclamation_mark: Pull Requests that need a code review
2. :thought_balloon: Pull Requests that need quality assurance
3. :white_check_mark: Pull Requests that are ready to be merged

These are sorted based on GitHub labels attached to pull requests. You can configure your labels in your `lita_config`.

You will also need a personal access token for an account that has access to all of the repositories that are to be scraped. You can get one of these [here](https://github.com/settings/applications). You'll need to store the access token as an environment variable on Heroku or your server.

Add the following configuration lines to your `lita_config`:

``` ruby
config.handlers.pullrequests.access_token = ENV["GITHUB_ACCESS_TOKEN"]
config.handlers.pullrequests.repos = ["username/reponame"]
config.handlers.pullrequests.review_label = "needs-review"
config.handlers.pullrequests.merge_label  = "ready-for-merge"
config.handlers.pullrequests.qa_label     = "qa-needed"
```

## Usage

```
> @robot: give me something to review for reponame
...

> @robot: summarize pull requests
....

> @robot: set pull requests reminder for 0 20 * * 1-5
....

> @robot: show pull requests reminder
....

> @robot: stop reminding me about pull requests
....
```

## License

[MIT](http://opensource.org/licenses/MIT)
