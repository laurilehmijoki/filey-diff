require_relative 'spec_helper'

shared_examples "a data source" do |source|
  let(:data_source) { described_class.new(source) }

  it 'normalises the objects into FileObjects' do
    data_source.get_file_objects[0].path.should eq('./cameron/80s/')
    data_source.get_file_objects[0].name.should eq('aliens.txt')
  end

  it 'normalises the objects into FileObjects' do
    data_source.get_file_objects[1].path.should eq('./cameron/90s/')
    data_source.get_file_objects[1].name.should eq('t2.txt')
  end

  it 'normalises the objects into FileObjects' do
    data_source.get_file_objects[2].path.should eq('./')
    data_source.get_file_objects[2].name.should eq('movies.txt')
  end

  it 'normalises the objects into FileObjects' do
    data_source.get_file_objects.each { |file_object|
      file_object.should be_an_instance_of(Filey::FileObject)
    }
  end
end

objects = [
  { :path => '/cameron/80s/aliens.txt', :mtime => Time.now },
  { :path => '/cameron/90s/t2.txt', :mtime => Time.now },
  { :path => '/movies.txt', :mtime => Time.now }
]

describe Filey::DataSources::AwsSdkS3 do
  s3_bucket = S3Bucket.new(
    objects.map { |object| S3Object.new(object[:path], object[:mtime]) }
  )
  it_should_behave_like "a data source", s3_bucket
end

describe Filey::DataSources::FileSystem do
  require 'tmpdir'
  @directory = Dir.mktmpdir
  objects.each { |object|
    fs_path = @directory + object[:path]
    FileUtils.mkdir_p(fs_path.scan(/(.*\/)/).first.first)
    File.open(fs_path, 'w') do |file|
      file.write 'test'
    end
  }
  it_should_behave_like "a data source", @directory
end
