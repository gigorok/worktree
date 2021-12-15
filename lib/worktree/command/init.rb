# frozen_string_literal: true

module Worktree
  module Command
    class Init # :nodoc:
      def initialize(uri, name:, path:, remote: 'origin')
        @uri = uri
        @path = File.expand_path path
        @remote = remote
        @name = name || build_name
      end

      def do!
        FileUtils.mkdir_p "#{@path}/#{@name}"

        Dir.chdir "#{@path}/#{@name}" do
          @git = Git.clone(@uri, 'master', remote: @remote, log: Worktree.logger)
        end
      end

      private

      def build_name
        URI(@uri).path.split('/').last[0..-5] # remove .git
      end
    end
  end
end
