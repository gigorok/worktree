# frozen_string_literal: true

module Worktree
  class Project # :nodoc:
    def self.resolve(branch, project_dir: nil)
      project_key = project_key_by_branch(branch)
      # try to find project key by dir (cherry-pick or open case)
      project_key = project_key_by_dir(project_dir) if project_key.nil? && project_dir
      new(project_key)
    end

    def initialize(key)
      @key = key
    end

    def copy_files
      if @key
        Worktree::Config.config.dig('projects', @key, 'copy_files') || []
      else
        []
      end
    end

    def root
      if @key
        Worktree::Config.config.dig('projects', @key, 'root').chomp('/')
      else
        Dir.pwd
      end
    end

    def self.project_key_by_branch(branch)
      project_keys = Worktree::Config.config['projects'].keys
      return nil if project_keys.empty?

      re = Regexp.new("^(#{project_keys.join('|')})\-")
      (branch.match(re) || [])[1]
    end

    def self.project_key_by_dir(dir)
      project_keys = Worktree::Config.config['projects'].keys
      return nil if project_keys.empty?

      project_key = nil
      Worktree::Config.config['projects'].each do |key, options|
        if options['root'].chomp('/') == dir
          project_key = key
          break
        end
      end
      project_key
    end

    private_class_method :project_key_by_branch, :project_key_by_dir
  end
end
