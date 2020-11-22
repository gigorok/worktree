# frozen_string_literal: true

require 'tty-prompt'

module Worktree
  module Command
    class Add
      def initialize(branch, from:, project_dir:, launcher_vars: {})
        @branch = branch
        @branch_remote = from
        @project_dir = File.expand_path project_dir || Project.resolve(branch).root
        @launcher_vars = launcher_vars
      end

      def do!
        # fetch all
        # TODO: silence log while fetching remotes
        git.remotes.each { |remote| git.fetch(remote, prune: true) }

        # update master
        git.pull('upstream', 'master')

        Worktree.run_command "git worktree add -b #{@branch} ../#{@branch} #{@branch_remote}", chdir: "#{@project_dir}/master"

        copy_files
        clone_dbs

        Launcher.new(
          project_dir: @project_dir,
          branch: @branch,
          extra_vars: @launcher_vars
        ).launch!
      end

      private

      def copy_files
        Feature::CopyFiles.new(
          project_dir: @project_dir,
          branch: @branch
        ).run!
      end

      def clone_dbs
        if File.exist?("#{@project_dir}/#{@branch}/config/database.yml")
          Feature::CloneDbs.new(
            project_dir: @project_dir,
            branch: @branch
          ).run! unless TTY::Prompt.new.no?('Clone development database?')
        end
      end

      def git
        @git ||= Worktree.git_for(@project_dir)
      end
    end
  end
end
