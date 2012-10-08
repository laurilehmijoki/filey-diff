require File.dirname(__FILE__) + '/spec_helper'

describe Filey::Comparison do
  before {
    @scifi = Filey::Filey.new('./', 'scifi.txt', Time.now,
                              '9cdfb439c7876e703e307864c9167a15')
    @scifi_changed = Filey::Filey.new('./', 'scifi.txt', Time.now,
                              '9cdfb439c7876e703e307864c9167DDD')
    @deep_space = Filey::Filey.new('./', 'abandoned.txt', Time.now,
                                   '9cdfb439c7876e703e307864c9167a15')
    @outdated_file_object = Filey::Filey.new('./', 'foo.txt', Time.now - 10,
                                             '9cdfb439c7876e703e307864c9167a15')
    @latest_file_object = Filey::Filey.new('./', 'foo.txt', Time.now,
                                           '9cdfb439c7876e703e307864c9167a15')
  }

  context 'finding outdated files' do
    before {
      data_source_a = DataSource.new([ @scifi, @latest_file_object ])
      data_source_b = DataSource.new([ @outdated_file_object, @deep_space ])
      @outdated_file_objects = Filey::Comparison.list_outdated(data_source_a, data_source_b)
    }

    it 'lists the outdated files when comparing two data sources' do
      @outdated_file_objects.length.should be(1)
    end

    it 'lists the outdated files when comparing two data sources' do
      @outdated_file_objects.should include(@outdated_file_object)
    end
  end

  context 'finding missing files' do
    before {
      data_source_a = DataSource.new([ @deep_space ])
      data_source_b = DataSource.new([ @scifi ])
      @missing_file_objects = Filey::Comparison.list_missing(data_source_a, data_source_b)
    }

    it 'lists the missing files when comparing two data sources' do
      @missing_file_objects.should include(@deep_space)
    end

    it 'lists the missing files when comparing two data sources' do
      @missing_file_objects.length.should be(1)
    end
  end

  context 'finding changed files' do
    before {
      data_source_a = DataSource.new([ @scifi ])
      data_source_b = DataSource.new([ @scifi_changed ])
      @changed_files = Filey::Comparison.list_changed(data_source_a, data_source_b)
    }

    it 'compares filey md5 hashes' do
      @changed_files.should include(@scifi_changed)
    end

    it 'compares filey md5 hashes' do
      @changed_files.length.should be(1)
    end

    context 'same md5 hashes' do
      before {
        data_source_a = DataSource.new([ @scifi ])
        data_source_b = DataSource.new([ @scifi ])
        @changed_files = Filey::Comparison.list_changed(data_source_a, data_source_b)
      }

      it 'notices when the md5 hashes are same' do
        @changed_files.length.should be(0)
      end
    end
  end

end
