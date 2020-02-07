# frozen_string_literal: true

require 'worktree/tab_completion'

module Worktree
  module TabCompletion
    class CLI # :nodoc:
      COMMAND_NEW = 'new'
      COMMAND_CHERRY_PICK = 'cherry_pick'
      COMMAND_REMOVE = 'remove'
      COMMAND_CONFIGURE = 'configure'
      COMMAND_OPEN = 'open'

      def find_matches_for(command_line)
        command_parameters = command_line.split(' ', -1)[1..-1]

        # 'worktree '
        # 'worktree n'
        if command_parameters.empty? || command_parameters.size == 1
          return [
            COMMAND_NEW,
            COMMAND_CHERRY_PICK,
            COMMAND_REMOVE,
            COMMAND_CONFIGURE,
            COMMAND_OPEN
          ]
        end

        # 'worktree new '
        # 'worktree new DAPI'
        if command_parameters.size == 2
          command, compl = command_parameters

          return BranchCompletion.new(compl).list if command == COMMAND_NEW
          return WorktreeCompletion.new(compl).list if command == COMMAND_OPEN
          return WorktreeCompletion.new(compl).list if command == COMMAND_REMOVE
          # TODO: cherry_pick/remove command
        end

        # 'worktree new BRANCHNAME '
        # 'worktree new BRANCHNAME --project-dir='
        # 'worktree new BRANCHNAME --project-dir=../'
        # 'worktree new BRANCHNAME --project-dir=/tmp/path'
        # 'worktree new BRANCHNAME --project-dir=~/path'
        # 'worktree new BRANCHNAME --from='
        # 'worktree new BRANCHNAME --from=upstream/'
        if command_parameters.size == 3
          command, branch, compl = command_parameters

          if command == COMMAND_NEW
            if compl.starts_with?('--project-dir=')
              return ProjectDirCompletion.new(compl[14..-1]).list.
                map { |dir| "--project-dir=#{dir}" }
            elsif command_parameters[2].starts_with?('--from=')
              project_dir = Project.resolve(branch).root
              return RemoteBranchCompletion.new(compl[7..-1], project_dir: project_dir).list.
                map { |b| "--from=#{b}" }
            else
              return ['--from=', '--project-dir=']
            end
          end

          if command == COMMAND_CHERRY_PICK
            if compl.starts_with?('--project-dir=')
              return ProjectDirCompletion.new(compl[14..-1]).list.
                map { |dir| "--project-dir=#{dir}" }
            elsif command_parameters[2].starts_with?('--to=')
              return RemoteBranchCompletion.new(compl[5..-1]).list.
                map { |dir| "--to=#{dir}" }
            else
              return ['--to=', '--project-dir=']
            end
          end

          if command == COMMAND_REMOVE
            if compl.starts_with?('--project-dir=')
              return ProjectDirCompletion.new(compl[14..-1]).list.
                map { |dir| "--project-dir=#{dir}" }
            else
              return ['--project-dir=']
            end
          end

          if command == COMMAND_OPEN
            if compl.starts_with?('--project-dir=')
              return ProjectDirCompletion.new(compl[14..-1]).list.
                map { |dir| "--project-dir=#{dir}" }
            else
              return ['--project-dir=']
            end
          end
        end

        if command_parameters.size == 4
          command, _branch_name, project_dir_or_from, compl = command_parameters

          if command == COMMAND_NEW
            if project_dir_or_from.starts_with?('--project-dir=')
              if compl.starts_with?('--from=')
                project_dir = project_dir_or_from[14..-1]
                return RemoteBranchCompletion.new(compl[7..-1], project_dir: project_dir).list.
                  map { |dir| "--from=#{dir}" }
              else
                return ['--from=']
              end
            elsif project_dir_or_from.starts_with?('--from=')
              if compl.starts_with?('--project-dir=')
                return ProjectDirCompletion.new(compl[14..-1]).list.
                  map { |dir| "--project-dir=#{dir}" }
              else
                return ['--project-dir=']
              end
            end
          end

          if command == COMMAND_CHERRY_PICK
            if project_dir_or_from.starts_with?('--project-dir=')
              if compl.starts_with?('--to=')
                project_dir = project_dir_or_from[14..-1]
                return RemoteBranchCompletion.new(compl[5..-1], project_dir: project_dir).list.
                  map { |dir| "--to=#{dir}" }
              else
                return ['--to=']
              end
            elsif project_dir_or_from.starts_with?('--to=')
              if compl.starts_with?('--project-dir=')
                return ProjectDirCompletion.new(compl[14..-1]).list.
                  map { |dir| "--project-dir=#{dir}" }
              else
                return ['--project-dir=']
              end
            end
          end
        end

        []
      end
    end
  end
end
