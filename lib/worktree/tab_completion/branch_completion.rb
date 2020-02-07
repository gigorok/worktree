# frozen_string_literal: true

require 'jira-ruby'

module Worktree
  module TabCompletion
    class BranchCompletion
      def initialize(compl)
        @compl = compl
      end

      def list
        issue_id = find_jira_issue_by(@compl)
        if issue_id
          jira_issue = jira_client.Issue.find(issue_id)
          ["#{issue_id}-#{clean_jira_summary(jira_issue)}"]
        else
          []
        end
      end

      private

      def find_jira_issue_by(comp_line)
        (comp_line.match(Worktree::JIRA_ISSUE_ID_REGEX) || [])[0]
      end

      def jira_client
        @jira_client ||= JIRA::Client.new(
          username: ENV['JIRA_USERNAME'],
          password: ENV['JIRA_PASSWORD'],
          site: ENV['JIRA_SITE'],
          context_path: '',
          auth_type: :basic
        )
      end

      def clean_jira_summary(jira_issue)
        raw_summary = jira_issue.summary
        raw_summary = raw_summary.strip

        # translate raw summary to branch name
        summary = raw_summary.split(' ').map(&:underscore).join('-')
        summary.gsub!('&&', 'and')
        summary.gsub!(/\(|\)/, '') # remove brackets
        summary.gsub!(/"|'|”|“|«|»/, '') # remove quotes
        summary.gsub!(/\.$/, '') # remove end period
        summary.gsub!(%r{/}, '-') # change back slash to minus
        summary.gsub!(/:|;/, '')
        summary
      end
    end
  end
end
