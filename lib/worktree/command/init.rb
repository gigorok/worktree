# frozen_string_literal: true

require 'tty-prompt'

module Worktree
  module Command
    class Init
      def initialize(uri, repo_path:)
        @uri = uri
        @repo_path = File.expand_path repo_path
      end

      def do!
        # clone git repo
        @git = Git.clone(@uri, tmp_repo_name, path: @repo_path)

        # rearrange repo folders
        FileUtils.mkdir_p "#{@repo_path}/#{repo_name}"
        git_master_path = "#{@repo_path}/#{repo_name}/master"
        FileUtils.mv "#{@repo_path}/#{tmp_repo_name}", git_master_path

        # reinit git from new path
        @git = Worktree.git_for(git_master_path)

        remote_name = TTY::Prompt.new.ask?('What is remote name?', default: 'origin')

        unless remote_name == 'origin'
          # add remote
          @git.add_remote remote_name, @uri

          # TODO: remove origin remote?
        end
      end

      private

      # example '123' * 2 = '123123'
      def tmp_repo_name
        repo_name * 2
      end

      def repo_name
        @repo_name ||= begin
                         u = URI(@uri)
                         n = u.path.split('/')
                         n.last[0..-5] # remove .git
                       end
      end
    end
  end
end
