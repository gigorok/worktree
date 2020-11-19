# frozen_string_literal: true

require 'tty-prompt'

module Worktree
  module Command
    class Open
      def initialize(branch, project_dir:)
        @branch = branch
        @project_dir = File.expand_path project_dir || Project.resolve(branch).root
        @worktree = "#{@project_dir}/#{@branch}"
      end

      def do!
        raise "Worktree #{@worktree} not found exists!" unless Dir.exist?(@worktree)
        raise 'No master repo found!' unless Dir.exist?("#{@project_dir}/master/.git")

        Launcher.new(
          project_dir: @project_dir,
          branch: @branch
        ).launch!
      end
    end
  end
end
