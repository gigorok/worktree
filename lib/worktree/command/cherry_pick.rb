# frozen_string_literal: true

require 'git'
require 'tty-prompt'

module Worktree
  module Command
    class CherryPick
      def initialize(commit, to:, project_dir:)
        @commit = commit[0..7] # short commit
        @branch_remote = to
        @branch = "cherry-pick-#{@commit}-to-#{@branch_remote.tr('/', '-')}"
        @project_dir = File.expand_path project_dir
      end

      def do!
        raise "Folder #{@branch} already exists!" if Dir.exist?("#{@project_dir}/#{@branch}")
        raise 'No master repo found!' unless Dir.exist?("#{@project_dir}/master/.git")

        # fetch all
        git.remotes.each(&:fetch)

        Worktree.run_command "git worktree add -b #{@branch} ../#{@branch} #{@branch_remote}", chdir: "#{@project_dir}/master"

        begin
          Worktree.run_command "git cherry-pick #{@commit} -m 1", chdir: "#{@project_dir}/#{@branch}"
        rescue Worktree::Error => e
          # bypass conflicts while cherry-picking
          Worktree.logger.warn { e.message }
        end

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
