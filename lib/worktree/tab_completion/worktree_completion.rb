# frozen_string_literal: true

module Worktree
  module TabCompletion
    class WorktreeCompletion
      def initialize(base_compl)
        @base_compl = base_compl.to_s.strip
        @project_dir = Project.resolve(@base_compl).root
      end

      def list
        # select only folders
        Dir.entries(@project_dir).
          select { |f| File.directory? "#{@project_dir.chomp('/')}/#{f}" }.
          reject { |d| d == '.' || d == '..' }
      end
    end
  end
end
