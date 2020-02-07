# frozen_string_literal: true

require 'yaml'

module Worktree
  module Config
    def config_file
      xdg_config_home = ENV.fetch('XDG_CONFIG_HOME') { "#{ENV['HOME']}/.config" }
      _config_file = "#{xdg_config_home}/worktree/worktree.yml"
      unless File.exist?(_config_file)
        raise Worktree::Error, "config file #{_config_file} not found!"
      end

      _config_file
    end

    def config
      YAML.load_file(Worktree::Config.config_file)
    end

    module_function :config_file, :config
  end
end
