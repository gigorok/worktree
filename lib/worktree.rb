# frozen_string_literal: true

require 'logger'
require 'tty-command'
require 'active_support/all'
require 'git'
require 'zeitwerk'

loader = Zeitwerk::Loader.for_gem
loader.setup

module Worktree
  def logger
    return @logger if defined?(@logger)

    @logger = Logger.new(STDOUT)
    @logger.level = Logger::INFO
    @logger
  end

  def run_command(cmd, options = {})
    command = TTY::Command.new(output: Worktree.logger)
    command.run cmd, options
  rescue TTY::Command::ExitError => e
    raise Error, e.message
  end

  def git_for(p_dir)
    Git.open("#{p_dir}/master", log: Worktree.logger)
  end

  module_function :logger, :run_command, :git_for
end
