# frozen_string_literal: true

module Worktree
  module Command
    class Remove
      NotMergedError = Class.new(StandardError)

      def initialize(branch, project_dir: nil, drop_db: false, drop_remote_branch: false, check_merged: false)
        @branch = branch
        @project_dir = File.expand_path project_dir || Project.resolve(branch).root
        @drop_db = drop_db
        @check_merged = check_merged
      end

      def do!
        if @check_merged && !git.branch('master').contains?(@branch)
          raise NotMergedError.new("#{@branch} is not merged into master")
        end

        drop_db! if @drop_db

        # remove stale worktree
        Worktree.run_command "git worktree remove #{@project_dir}/#{@branch} --force", chdir: git.dir

        # if remote branch exists then remove it also
        if @drop_remote_branch && Git.ls_remote(git.dir)['remotes'].keys.include?("origin/#{@branch}")
          git.push('origin', @branch, delete: true)
          Worktree.logger.info { "Remote branch #{@branch} was deleted successfully." }
        end

        # remove local branch
        git.branch(@branch).delete
      rescue NotMergedError => e
        Worktree.logger.error { e }
      end

      private

      def drop_db!
        db_manager_master = db_manager_for('master')
        db_manager = db_manager_for(@branch)
        return if db_manager.template == db_manager_master.template

        db_manager.dropdb!
        Worktree.logger.info { "Database #{db_manager.template} was dropped successfully." }
      end

      def db_manager_for(branch)
        DbManager.new("#{@project_dir}/#{branch}/config/database.yml")
      end

      def git
        @git ||= Worktree.git_for(@project_dir)
      end
    end
  end
end
