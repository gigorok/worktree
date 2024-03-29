# frozen_string_literal: true

module Worktree
  class Launcher # :nodoc:
    def initialize(project_dir:, branch:, extra_vars: {})
      @project_dir = project_dir
      @branch = branch
      @working_directory = "#{@project_dir}/#{@branch}".chomp('/')
      @extra_vars = extra_vars.symbolize_keys
    end

    def launch!
      Dir.chdir(@working_directory) { Kernel.system(command) }
    end

    private

    def command
      cmd = ENV.fetch('WORKTREE_LAUNCHER') { ENV.fetch('EDITOR', 'vim') }
      format(cmd, default_vars.merge(@extra_vars))
    end

    def default_vars
      { path: @working_directory, branch: @branch }
    end
  end
end
