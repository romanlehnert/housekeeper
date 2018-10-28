# frozen_string_literal: true

module Housekeeper
  class Cleaner
    attr_reader :archive_path
    attr_reader :min_age_seconds
    attr_reader :base_path

    IGNORES_FILE_NAME = '.housekeeper_ignore'
    DEFAULT_IGNORES = ['.', '..', 'archive'].freeze

    def initialize(base_path, min_age_seconds: nil)
      @base_path = base_path
      @archive_path = File.join(base_path, 'archive/')
      @min_age_seconds = min_age_seconds || 0
    end

    def archive
      Dir.mkdir(archive_path) unless Dir.exist?(archive_path)

      Dir.new(base_path).each do |entry|
        next if skip_entry?(entry)

        FileUtils.mv(entry_path(entry), archive_path)
      end
    end

    def delete
      Dir.new(base_path).each do |entry|
        next if skip_entry?(entry)

        FileUtils.remove_entry_secure(entry_path(entry))
      end
    end

    private

    def entry_path(entry_name)
      File.join(base_path, entry_name)
    end

    def skip_entry?(entry)
      return true if DEFAULT_IGNORES.include?(entry)
      return true if filed_ignores.any? { |pattern| File.fnmatch(pattern, entry) }
      return true if File.mtime(entry_path(entry)) > Time.now - min_age_seconds
    end

    def filed_ignores
      ignore_file_path = File.join(base_path, IGNORES_FILE_NAME)

      return [] unless File.exist?(ignore_file_path)

      File.new(ignore_file_path).readlines
    end
  end
end
