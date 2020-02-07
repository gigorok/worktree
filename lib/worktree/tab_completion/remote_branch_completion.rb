# frozen_string_literal: true

require 'git'

module Worktree
  module TabCompletion
    class RemoteBranchCompletion
      def initialize(base_compl, project_dir: nil)
        @base_compl = base_compl.to_s.strip
        @project_dir = project_dir || Dir.pwd
      end

      def list
        Git.ls_remote(git.dir)['remotes'].keys
      end

      private

      def git
        @git ||= Worktree.git_for(@project_dir)
      end
    end
  end
end
