# frozen_string_literal: true

module Worktree
  module Command
    class Configure # :nodoc:
      def do!
        system("#{editor} #{Worktree::Config.config_file}")
      end

      private

      def editor
        ENV.fetch('EDITOR') { 'vim' }
      end
    end
  end
end
