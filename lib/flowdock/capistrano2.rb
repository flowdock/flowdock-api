Capistrano::Configuration.instance(:must_exist).load do

  namespace :flowdock do
    task :read_current_deployed_branch do
      current_branch = capture("cat #{current_path}/BRANCH").chomp rescue "master"
      set :current_branch, current_branch
    end

    task :save_deployed_branch do
      begin
        run "echo '#{source.head.chomp}' > #{current_path}/BRANCH"
      rescue => e
        puts "Flowdock: error in saving deployed branch information: #{e.to_s}"
      end
    end

    task :set_flowdock_api do
      set :flowdock_deploy_env, fetch(:stage, fetch(:rails_env, ENV["RAILS_ENV"] || "production"))
      begin
        require 'grit'
        set :repo, Grit::Repo.new(".")
        config = Grit::Config.new(repo)
      rescue LoadError => e
        puts "Flowdock: you need to have Grit gem installed: #{e.to_s}"
      rescue => e
        puts "Flowdock: error in fetching your git repository information: #{e.to_s}"
      end

      begin
        flows = Array(flowdock_api_token).map do |api_token|
          Flowdock::Flow.new(:api_token => api_token,
          :source => "Capistrano deployment", :project => flowdock_project_name,
          :from => {:name => config["user.name"], :address => config["user.email"]})
        end
        set :flowdock_api, flows
      rescue => e
        puts "Flowdock: error in configuring Flowdock API: #{e.to_s}"
      end
    end

    task :notify_deploy_finished do
      # send message to the flow
      begin
        flowdock_api.each do |flow|
          flow.push_to_team_inbox(:format => "html",
            :subject => "#{flowdock_project_name} deployed with branch #{branch} on ##{flowdock_deploy_env}",
            :content => notification_message,
            :tags => ["deploy", "#{flowdock_deploy_env}"] | flowdock_deploy_tags)
        end unless dry_run
      rescue => e
        puts "Flowdock: error in sending notification to your flow: #{e.to_s}"
      end
    end

    def notification_message
      if branch == current_branch
        message = "<p>The following changes were just deployed to #{flowdock_deploy_env}:</p>"
        commits = repo.commits_between(previous_revision, current_revision).reverse

        unless commits.empty?
          commits.each do |c|
            short, long = c.message.split(/\n+/, 2)
            message << "\n<div style=\"margin-bottom: 10px\"><div style=\"height:30px;width:30px;float:left;margin-right:5px;\"><img src=\"https://secure.gravatar.com/avatar/#{Digest::MD5::hexdigest(c.author.email.downcase)}?s=30\" /></div>"
            message << "<div style=\"padding-left: 35px;\">#{CGI.escapeHTML(short)}<br/>"
            if long
              long.gsub!(/\n/, '<br />')
              message << '<p style="margin:5px 0px; padding: 0 5px; border-left: 3px solid #ccc">' + long + '</p>'
            end
            message << "<span style=\"font-size: 90%; color: #333\"><code>#{c.id_abbrev}</code> <a href=\"mailto:#{CGI.escapeHTML(c.author.email)}\">#{CGI.escapeHTML(c.author.name)}</a> on #{c.authored_date.strftime("%b %d, %H:%M")}</span></div></div>"
          end
        end
      else
        message = "Branch #{source.head} was deployed to #{flowdock_deploy_env}. Previously deployed branch was #{current_branch}."
      end
      message
    end
  end

  before "deploy:update_code", "flowdock:read_current_deployed_branch"
  before "flowdock:notify_deploy_finished", "flowdock:set_flowdock_api"
  ["deploy", "deploy:migrations"].each do |task|
    after task, "flowdock:notify_deploy_finished"
    after task, "flowdock:save_deployed_branch"
  end
end
