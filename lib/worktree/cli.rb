# frozen_string_literal: true

require 'worktree'
require 'thor'

module Worktree
  class CLI < Thor
    def self.exit_on_failure?
      true
    end

    desc 'new BRANCH', 'Create a new branch'
    option :from, default: 'upstream/master'
    option :project_dir
    option :launcher_vars, type: :hash, default: {}
    def new(branch)
      Worktree::Command::Add.new(branch,
                                 from: options[:from],
                                 project_dir: options[:project_dir],
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

    desc 'remove BRANCH', 'Remove branches'
    option :project_dir
    def remove(*branches)
      branches.each do |b|
        Worktree::Command::Remove.new(b,
                                      project_dir: options[:project_dir]).do!
      end
    end

    desc 'remove-stale', 'Remove all stale branches'
    option :project_dir
    def remove_stale
      Worktree::Command::RemoveStale.new(project_dir: options[:project_dir]).do!
    rescue TTY::Reader::InputInterrupt
      Worktree.logger.info { "You've interrupted removing of stale branches!" }
    end

    desc 'cherry_pick COMMIT', 'Create a new cherry pick'
    option :to, required: true
    option :project_dir, default: Dir.pwd
    option :launcher_vars, type: :hash, default: {}
    def cherry_pick(commit)
      Worktree::Command::CherryPick.new(commit,
                                        to: options[:to],
                                        project_dir: options[:project_dir],
                                        launcher_vars: options[:launcher_vars]).do!
    end

    desc 'configure', 'Configure worktree'
    def configure
      Worktree::Command::Configure.new.do!
    end

    desc 'init URI', 'Initialize new worktree'
    option :repo_path, required: true
    def init(uri)
      Worktree::Command::Init.new(uri,
                                  repo_path: options[:repo_path]).do!
    end
  end
end
