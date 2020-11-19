# frozen_string_literal: true

module Worktree
  module Command
    class RemoveStale
      def initialize(project_dir:)
        @project_dir = File.expand_path project_dir || Dir.pwd
      end

      def do!
        # update refs
        git.remotes.each { |remote| git.fetch(remote, prune: true) }
        git.pull('upstream', 'master')

        branches = Dir.entries(@project_dir).
          reject { |d| d == '.' || d == '..' || d == 'master' }.
          select { |f| File.directory?(f) }

        stale_branches = branches.select do |branch|
          git.branch('master').contains?(branch)
        end

        Worktree.logger.info { "You have #{stale_branches.size} stale branches!" }

        stale_branches.each_with_index do |stale_branch, index|
          Worktree.logger.info { "#{index + 1} of #{stale_branches.size}" }
          Remove.new(stale_branch, project_dir: @project_dir, update_refs: false).do!
        end
      end

      private

      def git
        @git ||= Worktree.git_for(@project_dir)
      end
    end
  end
end
