# frozen_string_literal: true

require 'tty-prompt'

module Worktree
  module Command
    class Add
      DEFAULT_BRANCH_REMOTE = 'upstream/master'

      def initialize(branch, from:, project_dir:)
        @branch = branch
        @branch_remote = from
        @project_dir = project_dir || Project.resolve(branch).root
        @worktree = "#{@project_dir}/#{@branch}"
      end

      def do!
        raise "Worktree #{@worktree} already exists!" if Dir.exist?(@worktree)
        raise 'No master repo found!' unless Dir.exist?("#{@project_dir}/master/.git")

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
          branch: @branch
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
        if File.exist?("#{@project_dir}/master/config/database.yml")
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
