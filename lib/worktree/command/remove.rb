# frozen_string_literal: true

module Worktree
  module Command
    class Remove
      def initialize(branch, project_dir:, update_refs: true)
        @branch = branch
        @project_dir = File.expand_path project_dir || Project.resolve(branch).root
        @worktree = "#{@project_dir}/#{@branch}"
        @update_refs = update_refs
      end

      def do!
        return unless Dir.exist?(@worktree)
        return unless TTY::Prompt.new.yes?("Do you want to remove #{@worktree}?")

        # update refs
        git.remotes.each { |remote| git.fetch(remote, prune: true) } if @update_refs

        unless git.branch('master').contains?(@branch)
          unless TTY::Prompt.new.yes?("The branch #{@branch} was not merged to master. Would you like to remove it anyway?")
            Worktree.logger.warn { "You've skipped removing the worktree #{@worktree}" }
            return
          end
        end

        drop_db! if File.exist?("#{@worktree}/config/database.yml")

        # remove stale worktree
        Worktree.run_command "git worktree remove #{@worktree} --force", chdir: "#{@project_dir}/master"

        # if remote branch exists then remove it also
        if Git.ls_remote(git.dir)['remotes'].keys.include?("origin/#{@branch}")
          if TTY::Prompt.new.yes?("Do you want to remove remote branch origin/#{@branch}?")
            git.push('origin', @branch, delete: true)
          end
        end

        # remove local branch
        git.branch(@branch).delete
      end

      private

      def drop_db!
        db_manager_master = db_manager_for('master')
        db_manager = db_manager_for(@branch)
        return if db_manager.template == db_manager_master.template

        if TTY::Prompt.new.yes?("Do you want to drop database #{db_manager.template}?")
          db_manager.dropdb!
        end
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
