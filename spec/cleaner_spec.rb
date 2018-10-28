# frozen_string_literal: true

require 'spec_helper'
require 'byebug'

RSpec.describe Housekeeper::Cleaner do
  include_context 'uses temp dir'

  subject { described_class.new(temp_dir, min_age_seconds: 60 * 60) }

  describe '#delete' do
    let(:action) { subject.delete }

    context 'with an empty folder' do
      it 'does not delete the folder' do
        expect { action }
          .to_not change { Dir.exist?(temp_dir) }.from(true)
      end
    end

    context 'with an existing file' do
      let(:file_name) { 'file_1' }
      let(:file_path) { File.join(temp_dir, file_name) }

      before do
        FileUtils.touch(file_path, mtime: mtime)
      end

      context 'when the mtime is before the max age' do
        let(:min_age_seconds) { 60 * 60 }
        let(:mtime) { Time.now - min_age_seconds - 1 }

        it 'deletes the file' do
          expect { action }
            .to change { File.exist?(file_path) }
            .from(true).to(false)
        end

        context 'when the file is ignored' do
          let(:ignore_file_name)  { '.housekeeper_ignore' }
          let(:ignore_file_path) { File.join(temp_dir, ignore_file_name) }

          before do
            File.write(ignore_file_path, ignores.join("\n"))
          end

          context 'when the file is ignored with a wildcard' do
            let(:ignores) { ['file_*'] }

            it 'does not delete the fil' do
              expect { action }
                .to_not change { File.exist?(file_path) }.from(true)
            end
          end

          context 'when the file is ignored explocitly' do
            let(:ignores) { ['file_1'] }

            it 'does not delete the fil' do
              expect { action }
                .to_not change { File.exist?(file_path) }.from(true)
            end
          end
        end
      end

      context 'when the mtime is after the max age' do
        let(:min_age_seconds) { 60 * 60 }
        let(:mtime) { Time.now - min_age_seconds + 1 }

        it 'does not delete the file' do
          expect { action }.to_not change { File.exist?(file_path) }
        end
      end
    end

    context 'with an existing directory' do
      let(:dir_name) { 'dir_1' }
      let(:dir_path) { File.join(temp_dir, dir_name) }

      before do
        Dir.mkdir(dir_path)
        FileUtils.touch(dir_path, mtime: mtime)
      end

      context 'when the mtime is before the max age' do
        let(:min_age_seconds) { 60 * 60 }
        let(:mtime) { Time.now - min_age_seconds - 1 }

        it 'deletes the dir' do
          expect { action }
            .to change { Dir.exist?(dir_path) }
            .from(true).to(false)
        end
      end

      context 'when the mtime is after the max age' do
        let(:min_age_seconds) { 60 * 60 }
        let(:mtime) { Time.now - min_age_seconds + 1 }

        it 'does not delete the file' do
          expect { action }.to_not change { Dir.exist?(dir_path) }
        end
      end
    end
  end

  describe '#archive' do
    let(:action) { subject.archive }
    let(:archive_dir_name) { 'archive' }
    let(:archive_dir_path) { File.join(temp_dir, archive_dir_name) }

    context 'with an empty folder' do
      it 'does not delete the folder' do
        expect { action }
          .to_not change { Dir.exist?(temp_dir) }.from(true)
      end

      context 'when there is no archive folder' do
        it 'creates an archive folder' do
          expect { action }
            .to change { Dir.exist?(archive_dir_path) }
            .from(false).to(true)
        end
      end
    end

    context 'with an existing directory' do
      let(:dir_name) { 'dir_1' }
      let(:dir_path) { File.join(temp_dir, dir_name) }
      let(:dir_path_in_archive) { File.join(temp_dir, archive_dir_name, dir_name) }

      before do
        Dir.mkdir(dir_path)
        FileUtils.touch(dir_path, mtime: mtime)
      end

      context 'when the mtime is before the max age' do
        let(:min_age_seconds) { 60 * 60 }
        let(:mtime) { Time.now - min_age_seconds - 1 }

        it 'moves the dir into the archive dir' do
          expect { action }
            .to change { Dir.exist?(dir_path_in_archive) }
            .from(false).to(true)
        end
      end

      context 'when the mtime is after the max age' do
        let(:min_age_seconds) { 60 * 60 }
        let(:mtime) { Time.now - min_age_seconds + 1 }

        it 'does not move the dir' do
          expect { action }.to_not change { Dir.exist?(dir_path) }
        end
      end
    end

    context 'with an existing file' do
      let(:file_name) { 'file_1' }
      let(:file_path) { File.join(temp_dir, file_name) }
      let(:file_path_in_archive) { File.join(temp_dir, archive_dir_name, file_name) }

      before do
        FileUtils.touch(file_path, mtime: mtime)
      end

      context 'when the mtime is before the max age' do
        let(:min_age_seconds) { 60 * 60 }
        let(:mtime) { Time.now - min_age_seconds - 1 }

        it 'moves the file into the archive folder' do
          expect { action }
            .to change { File.exist?(file_path_in_archive) }
            .from(false).to(true)
        end
      end

      context 'when the mtime is after the max age' do
        let(:min_age_seconds) { 60 * 60 }
        let(:mtime) { Time.now - min_age_seconds + 1 }

        it 'does not move the file into the archive folder' do
          expect { action }
            .to_not change { File.exist?(file_path_in_archive) }.from(false)
        end

        it 'leaves the file in its original dir' do
          expect { action }
            .to_not change { File.exist?(file_path) }.from(true)
        end
      end
    end
  end
end
