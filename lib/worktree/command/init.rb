# frozen_string_literal: true

module Worktree
  module Command
    class Init
      def initialize(uri, path:, remote: 'origin')
        @uri = uri
        @path = File.expand_path path
        @remote = remote
      end

      def do!
        Dir.chdir @path do
          @git = Git.clone(@uri, name, path: @repo_path, remote: @remote)
        end
      end

      private

      def name
        URI(@uri).path.split('/').last[0..-5] # remove .git
      end
    end
  end
end
