# frozen_string_literal: true

require 'tty-prompt'

module Worktree
  module Command
    class Open
      def initialize(branch, project_dir:)
        @branch = branch
        @project_dir = project_dir || Project.resolve(branch).root
        @worktree = "#{@project_dir}/#{@branch}"
      end

      def do!
        raise "Worktree #{@worktree} not found exists!" unless Dir.exist?(@worktree)
        raise 'No master repo found!' unless Dir.exist?("#{@project_dir}/master/.git")

        tmux
      end

      private

      def tmux
        project_dir_name = File.expand_path(@project_dir).chomp('/').split('/').last
        tmux_session_name = if @branch == 'master'
                              "#{project_dir_name}-#{@branch}"
                            else
                              @branch
                            end
        Feature::Tmux.new(
          project_dir: @project_dir,
          branch: @branch
        ).run!(tmux_session_name)
      end
    end
  end
end
