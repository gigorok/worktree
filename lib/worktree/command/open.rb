# frozen_string_literal: true

require 'tty-prompt'

module Worktree
  module Command
    class Open
      def initialize(branch, project_dir:, launcher_vars: {})
        @branch = branch
        @project_dir = File.expand_path project_dir || Project.resolve(branch).root
        @launcher_vars = launcher_vars
      end

      def do!
        Launcher.new(
          project_dir: @project_dir,
          branch: @branch,
          extra_vars: @launcher_vars
        ).launch!
      end
    end
  end
end
