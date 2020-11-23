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

        branches = Dir[@project_dir].
          select { |f| File.directory?(f) }.
          map { |f| File.basename(f) }.
          reject { |f| f == 'master' }

        stale_branches = branches.select do |branch|
          git.branch('master').contains?(branch)
        end

        Worktree.logger.info { "You have #{stale_branches.size} stale branches!" }

        stale_branches.each_with_index do |stale_branch, index|
          Worktree.logger.info { "#{index + 1} of #{stale_branches.size}" }
          Remove.new(stale_branch,
                     project_dir: @project_dir,
                     drop_db: true,
                     drop_remote_branch: true).do!
        end
      end

      private

      def git
        @git ||= Worktree.git_for(@project_dir)
      end
    end
  end
end
