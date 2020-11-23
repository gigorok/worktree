# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'worktree/version'

Gem::Specification.new do |spec|
  spec.name          = 'worktree'
  spec.version       = Worktree::VERSION
  spec.authors       = ['Igor Gonchar']
  spec.email         = ['igor.gonchar@gmail.com']

  spec.summary       = 'Manage your projects by git working tree feature'
  spec.homepage      = 'https://github.com/gigorok/worktree'
  spec.license       = 'MIT'

  spec.files         = Dir['{lib,bin}/**/**']
  spec.executables   = %w[worktree worktree_tab_completion]
  spec.require_paths = ['lib']
  spec.required_ruby_version = '>= 2.4.4'

  spec.add_dependency 'activesupport'
  spec.add_dependency 'git'
  spec.add_dependency 'jira-ruby'
  spec.add_dependency 'thor'
  spec.add_dependency 'tty-command'
  spec.add_dependency 'zeitwerk'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'byebug'
  spec.add_development_dependency 'rake', '>= 12.3.3'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rubocop'
end
