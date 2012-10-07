require_relative 'spec_helper'

describe Filey::Comparison do
  before {
    @scifi = Filey::FileObject.new('./', 'scifi.txt', Time.now)
    @deep_space = Filey::FileObject.new('./', 'abandoned.txt', Time.now)
    @outdated_file_object = Filey::FileObject.new('./', 'foo.txt', Time.now - 10)
    @latest_file_object = Filey::FileObject.new('./', 'foo.txt', Time.now)
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
end
