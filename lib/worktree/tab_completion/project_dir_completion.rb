# frozen_string_literal: true

module Worktree
  module TabCompletion
    class ProjectDirCompletion
      def initialize(base_compl)
        @base_compl = base_compl.to_s.strip
        if @base_compl.starts_with?('~')
          @replace_home = true
          @base_compl = "#{ENV['HOME']}/#{@base_compl[1..-1]}"
        end
      end

      def list
        if File.directory?(@base_compl)
          base_dir = @base_compl
        else
          # remove tail
          if @base_compl.starts_with?('/')
            if @base_compl.split('/').size == 2
              base_dir = '/'
            else
              base_dir = @base_compl.split('/')[0..-2].join('/')
            end
          else
            base_dir = @base_compl.split('/')[0..-2].join('/')
          end
        end

        base_dir = base_dir.presence || '.'

        # select only folders
        Dir.entries(base_dir.presence).
          select { |f| File.directory? "#{base_dir.chomp('/')}/#{f}" }.
          reject { |d| d == '.' || d == '..' }.
          map do |d|
            if @replace_home
              b = "~#{base_dir[ENV['HOME'].size+1..-1]}"
              "#{b.chomp('/')}/#{d}"
            elsif base_dir == '.'
              d
            else
              b = base_dir
              "#{b.chomp('/')}/#{d}"
            end
          end
      end
    end
  end
end
