# lita-pullrequests

A Lita handler to help you keep track of your pull requests.

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
config.handlers.pullrequests.review_label = "title of a label that represents a pr ready for merge"
```

## Usage

```
> @robot: give me something to review
...

> @robot: summarize pull requests
....
```

## License

[MIT](http://opensource.org/licenses/MIT)
