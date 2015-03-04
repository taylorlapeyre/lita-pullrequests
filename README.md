# lita-pullrequests

A Lita handler to help you keep track of your pull requests. It can automatically post in your channels and tell you about which pull requests need attention.

## Installation

Add lita-pullrequests to your Lita instance's Gemfile:

``` ruby
gem "lita-pullrequests"
```

## Configuration

Add the following configuration lines to your `lita_config`:

``` ruby
config.handlers.pullrequests.access_token = "a-github-api-access-token"
config.handlers.pullrequests.repo = "username/reponame"
config.handlers.pullrequests.review_label = "title of a label that represents a pr ready for review"
config.handlers.pullrequests.merge_label  = "title of a label that represents a pr ready for merge"
```

## Usage

```
> @robot: give me something to review
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
