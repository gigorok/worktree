# frozen_string_literal: true

module Worktree
  class Project
    def self.project_key_for(branch)
      project_keys = Worktree::Config.config['projects'].keys
      return nil if project_keys.empty?

      re = Regexp.new("^(#{project_keys.join('|')})\-")
      (branch.match(re) || [])[1]
    end

    def self.resolve(branch)
      new(project_key_for(branch))
    end

    def initialize(key)
      @key = key
    end

    def root
      if @key
        Worktree::Config.config.dig('projects', @key, 'root').chomp('/')
      else
        Dir.pwd
      end
    end
  end
end
