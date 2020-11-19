# frozen_string_literal: true

require 'yaml'

module Worktree
  module Feature
    class CloneDbs

      def initialize(project_dir:, branch:)
        @project_dir = project_dir
        @branch = branch
      end

      def run!
        @db_manager = DbManager.new("#{@project_dir}/#{@branch}/config/database.yml")
        @db_manager.createdb!(db_name)

        write!
      rescue StandardError => e
        # bypass error
        Worktree.logger.error { e.message }
      end

      private

      def write!
        new_spec = @db_manager.spec.dup
        if @db_manager.multi?
          new_spec['development']['primary']['database'] = db_name
        else
          new_spec['development']['database'] = db_name
        end
        # write changed database config back
        File.write("#{@project_dir}/#{@branch}/config/database.yml", new_spec.to_yaml)
      end

      def db_name
        # db name cannot be > 63 bytes
        db_suffix = '_development'
        max_db_prefix_length = 62 - db_suffix.length
        db_prefix = @branch[0..max_db_prefix_length]
        "#{db_prefix}#{db_suffix}"
      end
    end
  end
end
