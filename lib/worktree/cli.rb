# frozen_string_literal: true

require 'worktree'
require 'thor'

module Worktree
  class CLI < Thor # :nodoc:
    def self.exit_on_failure?
      true
    end

    desc 'new BRANCH', 'Create a new branch'
    option :from, default: 'upstream/master'
    option :project_dir
    option :launcher_vars, type: :hash, default: {}
    option :clone_db, type: :boolean, default: false
    option :fetch_remote, type: :boolean, default: true
    def new(branch)
      Worktree::Command::Add.new(branch,
                                 from: options[:from],
                                 project_dir: options[:project_dir],
                                 clone_db: options[:clone_db],
                                 fetch_remote: options[:fetch_remote],
                                 launcher_vars: options[:launcher_vars]).do!
    end

    desc 'open BRANCH', 'Open existing worktree'
    option :project_dir
    option :launcher_vars, type: :hash, default: {}
    def open(branch)
      Worktree::Command::Open.new(branch,
                                  project_dir: options[:project_dir],
                                  launcher_vars: options[:launcher_vars]).do!
    end

    desc 'remove BRANCH', 'Remove branch'
    option :project_dir
    option :drop_db, type: :boolean, default: false
    option :drop_remote_branch, type: :boolean, default: false
    option :check_merged, type: :boolean, default: false
    def remove(branch)
      Worktree::Command::Remove.new(branch,
                                    project_dir: options[:project_dir],
                                    drop_db: options[:drop_db],
                                    drop_remote_branch: options[:drop_remote_branch],
                                    check_merged: options[:check_merged]).do!
    end

    desc 'check-stale', 'Check stale branches'
    option :project_dir
    def check_stale
      Worktree::Command::CheckStale.new(project_dir: options[:project_dir]).do!
    end

    desc 'remove-stale', 'Remove all stale branches'
    option :project_dir
    def remove_stale
      Worktree::Command::RemoveStale.new(project_dir: options[:project_dir]).do!
    end

    desc 'cherry_pick COMMIT', 'Create a new cherry pick'
    option :to, required: true
    option :project_dir, default: Dir.pwd
    option :launcher_vars, type: :hash, default: {}
    option :clone_db, type: :boolean, default: false
    def cherry_pick(commit)
      Worktree::Command::CherryPick.new(commit,
                                        to: options[:to],
                                        project_dir: options[:project_dir],
                                        clone_db: options[:clone_db],
                                        launcher_vars: options[:launcher_vars]).do!
    end

    desc 'configure', 'Configure worktree'
    def configure
      Worktree::Command::Configure.new.do!
    end

    desc 'init URI', 'Initialize new worktree'
    option :path, default: Dir.pwd
    option :remote, default: 'origin'
    option :name
    def init(uri)
      Worktree::Command::Init.new(uri,
                                  path: options[:path],
                                  name: options[:name],
                                  remote: options[:remote]).do!
    end
  end
end
