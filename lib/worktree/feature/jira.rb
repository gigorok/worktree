# frozen_string_literal: true

require 'jira-ruby'

module Worktree
  module Feature
    class Jira
      def initialize(project_dir:, branch:)
        @project_dir = project_dir
        @branch = branch
      end

      def run!
        if jira_issue?
          prompt = "Jira issue #{jira_issue_id} status: #{jira_issue.status.name}. Would you like to change it?"
          jira_process! unless TTY::Prompt.new.no?(prompt)
        end

        super
      end

      private

      def jira_client
        @jira_client ||= JIRA::Client.new(jira_client_options)
      end

      def jira_client_options
        {
          username: ENV['JIRA_USERNAME'],
          password: ENV['JIRA_PASSWORD'],
          site: ENV['JIRA_SITE'],
          context_path: '',
          auth_type: :basic
        }
      end

      def jira_issue?
        return false unless jira_issue_id

        jira_issue_id =~ Worktree::JIRA_ISSUE_ID_REGEX
      end

      def jira_process!
        transition = choose_transition
        apply_transition!(transition) if transition != -1
      rescue StandardError => e
        Worktree.logger.error { e.message }
      end

      def jira_issue_id
        (@branch.match(/^\w+\-\d+/) || [])[0]
      end

      def jira_issue
        @jira_issue ||= jira_client.Issue.find(jira_issue_id)
      end

      def apply_transition!(transition)
        jira_issue.transitions.build.save!(transition: { id: transition.id })
      end

      def choose_transition
        TTY::Prompt.new.select('Choose a transition?', cycle: true) do |menu|
          menu.enum '.'
          menu.choice 'Skip it', -1
          jira_issue.transitions.all.each do |s|
            menu.choice s.name, s
          end
        end
      end
    end
  end
end
