# frozen_string_literal: true

module Worktree
  class Launcher # :nodoc:
    def initialize(project_dir:, branch:)
      @project_dir = project_dir
      @branch = branch
      @working_directory = "#{@project_dir}/#{@branch}".chomp('/')
    end

    def launch!
      Dir.chdir(@working_directory) { Kernel.system(command) }
    end

    private

    def command
      cmd = ENV.fetch('WORKTREE_LAUNCHER') { ENV.fetch('EDITOR', 'vim') }
      format(cmd, replace_vars)
    end

    def replace_vars
      {
        worktree_dir: @working_directory,
        worktree_branch: @branch
      }
    end
  end
end
