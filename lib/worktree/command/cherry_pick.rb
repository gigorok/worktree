# frozen_string_literal: true

module Worktree
  module Command
    class CherryPick
      def initialize(commit, to:, project_dir:, launcher_vars: {}, clone_db: false)
        @commit = commit[0..7] # short commit
        @to = to
        @branch = "cherry-pick-#{@commit}-to-#{@to.tr('/', '-')}"
        @project_dir = File.expand_path project_dir
        @clone_db = clone_db
        @launcher_vars = launcher_vars
      end

      def do!
        # fetch all remotes
        git.remotes.each { |remote| git.fetch(remote, prune: true) }

        # create new git worktree
        Worktree.run_command "git worktree add -b #{@branch} ../#{@branch} #{@to}", chdir: git.dir

        # cherry-pick specified commit into specified branch
        begin
          Worktree.run_command "git cherry-pick #{@commit} -m 1", chdir: "#{@project_dir}/#{@branch}"
        rescue Worktree::Error => e
          # bypass conflicts while cherry-picking
          Worktree.logger.warn { e.message }
        end

        # copy files specified in configuration into new folder
        Feature::CopyFiles.new(project_dir: @project_dir, branch: @branch).run!

        # clone PG database
        Feature::CloneDbs.new(project_dir: @project_dir, branch: @branch).run! if @clone_db

        # launch in editor
        Launcher.new(project_dir: @project_dir, branch: @branch, extra_vars: @launcher_vars).launch!
      end

      private

      def git
        @git ||= Worktree.git_for(@project_dir)
      end
    end
  end
end
