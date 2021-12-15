# frozen_string_literal: true

module Worktree
  module Command
    class CheckStale
      def initialize(project_dir:)
        @project_dir = File.expand_path project_dir || Dir.pwd
      end

      def do!
        # update refs
        git.remotes.each { |remote| git.fetch(remote, prune: true) }
        git.pull('upstream', 'master')

        branches = Dir.entries(@project_dir).
                   select { |f| File.directory?("#{@project_dir}/#{f}}") }.
                   reject { |f| ['master', '.', '..'].include?(f) }

        stale_branches = branches.select do |branch|
          git.branch('master').contains?(branch)
        end

        Worktree.logger.info { "You have #{stale_branches.size} stale branches!" }
      end

      private

      def git
        @git ||= Worktree.git_for(@project_dir)
      end
    end
  end
end
