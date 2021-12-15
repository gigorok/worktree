# frozen_string_literal: true

module Worktree
  module Command
    class Add # :nodoc:
      def initialize(branch, from:, project_dir:, launcher_vars: {}, clone_db: false, fetch_remote: true)
        @branch = branch
        @from = from
        @project_dir = File.expand_path project_dir || Project.resolve(branch).root
        @launcher_vars = launcher_vars
        @clone_db = clone_db
        @fetch_remote = fetch_remote
      end

      def do!
        # fetch git remote if allowed
        git.fetch(remote, prune: true) if @fetch_remote

        # create new git worktree
        Worktree.run_command "git worktree add -b #{@branch} ../#{@branch} #{@from}", chdir: git.dir

        # copy files specified in configuration into new folder
        Feature::CopyFiles.new(project_dir: @project_dir, branch: @branch).run!

        # clone PG database
        Feature::CloneDbs.new(project_dir: @project_dir, branch: @branch).run! if @clone_db

        # launch in editor
        Launcher.new(project_dir: @project_dir, branch: @branch, extra_vars: @launcher_vars).launch!
      end

      private

      def remote
        @from.split('/')[0]
      end

      def git
        @git ||= Worktree.git_for(@project_dir)
      end
    end
  end
end
