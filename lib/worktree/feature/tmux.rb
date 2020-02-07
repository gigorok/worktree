# frozen_string_literal: true

module Worktree
  module Feature
    class Tmux

      class VimEditor
        attr_reader :window_name

        def initialize(cwd:)
          @cwd = cwd
          @window_name = 'vim'
        end

        # open Gemfile if present
        def cmd
          if File.exist?("#{@cwd}/Gemfile")
            'vim Gemfile'
          else
            'vim'
          end
        end
      end

      def initialize(project_dir:, branch:)
        @project_dir = project_dir
        @branch = branch
        @working_directory = "#{@project_dir}/#{@branch}".chomp('/')
      end

      def run!(session_name)
        if session_exist?(session_name)
          Worktree.logger.info { "TMUX session #{session_name} already exist" }
          # TODO: ask for attach to it
          return
        end

        Worktree.run_command "tmux new-session -t #{session_name} -d", chdir: @working_directory
        Worktree.run_command "tmux new-window -d -t #{session_name} -n #{editor.window_name}", chdir: @working_directory
        Worktree.run_command "tmux send-keys -t #{session_name}:2 \"#{editor.cmd}\" C-m"
        Worktree.run_command "tmux select-window -t #{session_name}:2" # select vim window
        if inside_tmux?
          Kernel.system "tmux switch -t #{session_name}"
        else
          Kernel.system "tmux attach-session -t #{session_name}"
        end
      end

      private

      def editor
        return @editor if defined?(@editor)

        @editor = VimEditor.new(cwd: @working_directory)
      end

      def inside_tmux?
        Worktree.run_command('echo $TMUX').out.strip.present?
      end

      def session_exist?(name)
        cmd = "tmux list-sessions -F '#S' | awk '/'#{name}/' {print $1}'"
        Worktree.run_command(cmd).out.strip.present?
      end
    end
  end
end
