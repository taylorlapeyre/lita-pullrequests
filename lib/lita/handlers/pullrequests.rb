module Lita
  module Handlers
    class Pullrequests < Handler
      config :access_token, type: String, required: true
      config :repo,         type: String, required: true
      config :review_label, type: String, required: false
      config :merge_label,  type: String, required: false

      route(/^(pull request( me)?)|(give me something to review)$/, :get_random_pr, command: true, help: {
        "give me something to review" => "Shows you a random pull request that needs reviewing.",
        "pull request (me)" => "Shows you a random pull request that needs reviewing."
      })

      route(/^(summarize|all) pull requests$/, :list_all_pull_requests, command: true, help: {
        "(summarize|all) pull requests" => "Lists all pull requests that need action."
      })


      # Helper method
      def truncate(str, truncate_at, options = {})
        return str unless str.length > truncate_at

        omission = options[:omission] || '...'
        length_with_room_for_omission = truncate_at - omission.length
        stop = if options[:separator]
           str.rindex(options[:separator], length_with_room_for_omission) || length_with_room_for_omission
        else
          length_with_room_for_omission
        end

        "#{str[0, stop]}#{omission}"
      end

      def fetch_pull_requests
        url    = "https://api.github.com/repos/#{config.repo}/issues"
        req    = http.get(url, access_token: config.access_token)
        issues = MultiJson.load(req.body)
        issues.select { |issue| issue["pull_request"] }
      end

      def get_random_pr(chat)
        pr = pulls_that_need_reviews.sample
        if pr
          title, user, body = pr["title"], pr["user"]["login"], truncate(pr["body"], 200)
          url = pr["pull_request"]["html_url"]

          chat.reply %Q(
  #{title} - #{user}
  #{url}
  -------------------
  #{body}
)
        else
          chat.reply "No pull requests need reviews right now!"
        end
      end

      def pulls_that_need_reviews
        pulls = fetch_pull_requests
        review_label = config.review_label || "Needs Review"

        pulls.select do |pr|
          pr["labels"].any? { |label| label["name"] == config.review_label }
        end
      end

      def pulls_that_need_merging
        pulls = fetch_pull_requests
        merge_label = config.merge_label || "Ready To Merge"

        pulls.select do |pr|
          pr["labels"].any? { |label| label["name"] == config.merge_label }
        end
      end

      def list_all_pull_requests(chat)
        response = ":heavy_exclamation_mark: *Pull Requests that need review*:\n"

        response += pulls_that_need_reviews.map do |pr|
          title, user = pr["title"], pr["user"]["login"]
          url = pr["pull_request"]["html_url"]
          "- _#{title}_ - #{user} \n    #{url}"
        end.join("\n\n")

        response += "\n\n\n:white_check_mark: *Pull Requests that are ready for merging*:\n"

        response += pulls_that_need_merging.map do |pr|
          title, user = pr["title"], pr["user"]["login"]
          url = pr["pull_request"]["html_url"]
          "- _#{title}_ - #{user} \n    #{url}"
        end.join("\n\n")

        chat.reply(response)
      end
    end

    Lita.register_handler(Pullrequests)
  end
end
