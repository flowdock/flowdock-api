require 'flowdock'
require 'grit'

Capistrano::Configuration.instance(:must_exist).load do
  set :flowdock_send_notification, false

  namespace :flowdock do
    task :set_flowdock_api do
      config = Grit::Config.new(repo)
      set :flowdock_api, Flowdock::Flow.new(:api_token => flowdock_api_token, 
        :source => "Capistrano deployment", 
        :from => {:name => config["user.name"], :address => config["user.email"]})
    end

    task :trigger_notification do
      set :flowdock_send_notification, true
    end

    task :notify_deploy_finished do
      # send message to the flow
      flow.send_message(:format => "html", 
        :subject => "#{flowdock_project_name} deployed with branch #{branch} on ##{rails_env}", 
        :content => notification_message, 
        :tags => ["deploy", "##{rails_env}"].merge(flowdock_deploy_tags))
    end

    def notification_message
      if branch == current_branch || stage == :production
        message = "<p>The following changes were just deployed to #{host}:</p>"
        commits = repo.commits_between(capture("cat #{previous_release}/REVISION").chomp, current_revision).reverse

        unless commits.empty?
          commits.each do |c|
            short, long = c.message.split(/\n+/, 2)

            message << "\n<div style=\"margin-bottom: 10px\"><div class=\"ui-corner-all\" style=\"background:url(http://gravatar.com/avatar/#{MD5::md5(c.author.email.downcase)}?s=30) no-repeat scroll center;height:30px;width:30px;float:left;margin-right:5px;\">&nbsp;</div>"
            message << "<div style=\"padding-left: 35px;\">#{CGI.escapeHTML(short)}<br/>"
            if long
              long.gsub!(/\n/, '<br />')
              message << '<p style="margin:5px 0px; padding: 0 5px; border-left: 3px solid #ccc">' + long + '</p>'
            end
            message << "<span style=\"font-size: 90%; color: #333\"><code>#{c.id_abbrev}</code> <a href=\"mailto:#{CGI.escapeHTML(c.author.email)}\">#{CGI.escapeHTML(c.author.name)}</a> on #{c.authored_date.strftime("%b %d, %H:%M")}</span></div></div>"
          end
        end
      else
        message = "Branch #{source.head} was deployed to #{host}. Previously deployed branch was #{current_branch}."
      end
    end
  end

  before "deploy", "flowdock:trigger_notification"
  before "flowdock:notify_deploy_finished", "flowdock:set_flowdock_api"
  after "deploy", "flowdock:notify_deploy_finished"
end
