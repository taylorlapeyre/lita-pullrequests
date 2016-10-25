require "rufus-scheduler"

module Lita
  module Handlers
    class Pullrequests < Handler
      config :access_token, type: String, required: true
      config :repos,        type: Array,  required: true
      config :review_label, type: String, required: false
      config :merge_label,  type: String, required: false
      config :qa_label,     type: String, required: false

      on :loaded, :remember_reminder

      SCHEDULER = Rufus::Scheduler.new
      REDIS_KEY = "pullrequests-cron"

      route(/^give me something to review for (.*)$/, :get_random_pr, command: true, help: {
        "give me something to review for REPO NAME" => "Shows you a random pull request that needs reviewing.",
      })

      route(/^(summarize|all) pull requests$/, :list_all_pull_requests, command: true, help: {
        "(summarize|all) pull requests" => "Lists all pull requests that need action."
      })

      route(/^set pull request(s)? reminder for (.*)$/, :set_reminder, command: true, help: {
        "set pull request(s)? reminder for CRON EXPRESSION" => "Sets a cron task that will trigger a pr summary."
      })

      route(/^stop reminding me about pull requests$/, :remove_reminder, command: true, help: {
        "stop reminding me about pull requests" => "Shows you info about your next pull request reminder."
      })

      route(/^show pull request(s)? reminder$/, :show_reminder, command: true, help: {
        "show pull request(s) reminder" => "Shows you info about your next pull request reminder."
      })

      def remember_reminder(payload)
        reminder = redis.hgetall(REDIS_KEY)["reminder-info"]
        if reminder
          info = MultiJson.load(reminder)
          job  = SCHEDULER.cron info["cron_expression"] do |job|
            target = Source.new(user: info["u_id"], room: info["room"])
            robot.send_messages(target, formatted_pull_request_summary)
          end

          log.info "Created cron job: #{info['cron_expression']}."
        else
          log.info "no reminder found."
        end
      end

      def fetch_pull_requests
        config.repos.map do |repo|
          url    = "https://api.github.com/repos/#{repo}/issues"
          req    = http.get(url, access_token: config.access_token)
          issues = MultiJson.load(req.body)
          issues.select { |issue| issue["pull_request"] }
        end.flatten
      end

      def get_random_pr(chat)
        pulls_by_repo = pulls_that_need_reviews.group_by { |pr| pr["url"].split("/")[-3] }
        repo  = chat.matches[0][0]

        if config.repos.map { |r| r.split("/")[1] }.include?(repo)
          pulls = pulls_by_repo[repo]
          if pulls
            pr = pulls.sample
            title, user, url = pr["title"], pr["user"]["login"], pr["pull_request"]["html_url"]
            chat.reply "_#{title}_ - #{user} \n    #{url}"
          else
            chat.reply "No pull requests need a review right now!"
          end
        else
          chat.reply "I'm not configured for a repo with that name."
        end
      end

      def pulls_that_need_reviews
        pulls = fetch_pull_requests
        review_label = config.review_label || "Needs Review"

        pulls.select do |pr|
          pr["labels"] && pr["labels"].any? { |label| label["name"] == config.review_label }
        end
      end

      def pulls_that_need_merging
        pulls = fetch_pull_requests
        merge_label = config.merge_label || "Ready To Merge"

        pulls.select do |pr|
          pr["labels"] && pr["labels"].any? { |label| label["name"] == config.merge_label }
        end
      end

      def pulls_that_need_qa
        pulls = fetch_pull_requests
        merge_label = config.qa_label || "QA Needed"

        pulls.select do |pr|
          pr["labels"] && pr["labels"].any? { |label| label["name"] == config.qa_label }
        end
      end

      def formatted_pull_request_summary
        {
          ":heavy_exclamation_mark: *Pull Requests that need review*:\n"     => pulls_that_need_reviews,
          ":thought_balloon: *Pull Requests that need QA*:\n"                => pulls_that_need_qa,
          ":white_check_mark: *Pull Requests that are ready for merging*:\n" => pulls_that_need_merging
        }.map do |heading, pulls|
          heading + if pulls.any?
            pulls.map do |pr|
              msg = "- _#{pr['title']}_ - #{pr['user']['login']} \n    #{pr['pull_request']['html_url']}"
              msg << "\n:point_right: #{pr['assignees'].collect {|a| a['login']}.join(',')}" unless pr['assignees'].empty?
              msg
            end.join("\n\n")
          else
            "_None!_\n"
          end
        end.join("\n\n")
      end

      def list_all_pull_requests(chat)
        chat.reply(formatted_pull_request_summary)
      end

      def set_reminder(chat)
        input = chat.matches[0][1].split(" ")
        cron_expression = input[0..4].join(" ")
        job = SCHEDULER.cron cron_expression do |job|
          list_all_pull_requests(chat)
        end

        redis.hset(REDIS_KEY, "reminder-info", {
          :cron_expression => cron_expression,
          :j_id => job,
          :u_id => chat.message.source.user.id,
          :room => chat.message.source.room
        }.to_json)

        chat.reply("I will post a pull request summary according to this cron: #{cron_expression}")
      end

      def show_reminder(chat)
        reminder = redis.hgetall(REDIS_KEY)["reminder-info"]
        if reminder
          info = MultiJson.load(reminder)
          chat.reply "I will remind you in channel #{info["room"]} at #{info["cron_expression"]}"
        else
          chat.reply "Your reminder is not set."
        end
      end

      def remove_reminder(chat)
        reminder = redis.hgetall(REDIS_KEY)["reminder-info"]
        if reminder
          info = MultiJson.load(reminder)
          SCHEDULER.unschedule(info["j_id"])
          redis.hdel(REDIS_KEY, "reminder-info")
          chat.reply "okay, I turned off your reminder."
        else
          chat.reply "Your reminder is not set."
        end
      end
    end

    Lita.register_handler(Pullrequests)
  end
end
