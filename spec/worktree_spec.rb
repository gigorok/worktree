# frozen_string_literal: true

RSpec.describe Worktree do
  it 'has a version number' do
    expect(Worktree::VERSION).not_to be nil
  end
end
