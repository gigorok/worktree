# frozen_string_literal: true

require 'fileutils'

module Worktree
  module Feature
    class CopyFiles

      def initialize(project_dir:, branch:)
        @project_dir = project_dir
        @branch = branch
      end

      def run!
        files_to_copy.each { |path| copy_file(path) }
      end

      private

      def files_to_copy
        Worktree::Project.resolve(@branch, project_dir: @project_dir).copy_files
      end

      def copy_file(file)
        master_path = "#{@project_dir}/master/#{file}"
        if File.exist?(master_path)
          FileUtils.cp_r master_path, "#{@project_dir}/#{@branch}/#{file}"
        else
          print "The path #{master_path} was not found!"
        end
      end
    end
  end
end
