# frozen_string_literal: true

require 'yaml'

module Worktree
  class DbManager
    attr_reader :spec

    def initialize(spec_file, environment = 'development')
      @spec = YAML.load_file(spec_file)
      @environment = environment
    end

    def environment_spec
      @spec.fetch(@environment, {})
    end

    def multi?
      environment_spec.key? 'primary'
    end

    def db_port
      if multi?
        environment_spec.dig('primary', 'port')
      else
        environment_spec['port']
      end
    end

    def db_host
      if multi?
        environment_spec.dig('primary', 'host')
      else
        environment_spec['host']
      end
    end

    def template
      if multi?
        environment_spec.dig('primary', 'database')
      else
        environment_spec['database']
      end
    end

    def createdb!(db_name)
      cmd = if db_port
              "createdb -h #{db_host} -p #{db_port} -T #{template} #{db_name}"
            else
              "createdb -h #{db_host} -T #{template} #{db_name}"
            end
      Worktree.run_command cmd
    end

    def dropdb!
      cmd = if db_port
              "dropdb -h #{db_host} -p #{db_port} #{template}"
            else
              "dropdb -h #{db_host} #{template}"
            end
      Worktree.run_command cmd
    end
  end
end
