# frozen_string_literal: true

require 'tmpdir'
require 'rspec'

RSpec.shared_context 'uses temp dir' do
  around do |example|
    Dir.mktmpdir('rspec-') do |dir|
      @temp_dir = dir
      example.run
    end
  end

  attr_reader :temp_dir
end
