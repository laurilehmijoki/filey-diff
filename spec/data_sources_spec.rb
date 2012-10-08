require File.dirname(__FILE__) + '/spec_helper'

shared_examples "a data source" do |source|
  let(:data_source) { described_class.new(source) }

  it 'normalises the objects into Fileys' do
    filey = data_source.get_fileys.sort[0]
    filey.path.should eq('./cameron/80s/')
    filey.name.should eq('aliens.txt')
  end

  it 'normalises the objects into Fileys' do
    filey = data_source.get_fileys.sort[1]
    filey.path.should eq('./cameron/90s/')
    filey.name.should eq('t2.txt')
  end

  it 'normalises the objects into Fileys' do
    filey = data_source.get_fileys.sort[2]
    filey.path.should eq('./')
    filey.name.should eq('movies.txt')
  end

  it 'normalises the objects into Fileys' do
    data_source.get_fileys.each { |file_object|
      file_object.should be_an_instance_of(Filey::Filey)
    }
  end
end

objects = [
  { :path => 'cameron/80s/aliens.txt', :mtime => Time.now },
  { :path => 'cameron/90s/t2.txt', :mtime => Time.now },
  { :path => 'movies.txt', :mtime => Time.now }
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
    fs_path = "#{@directory}/#{object[:path]}"
    FileUtils.mkdir_p(fs_path.scan(/(.*\/)/).first.first)
    File.open(fs_path, 'w') do |file|
      file.write 'test'
    end
  }
  it_should_behave_like "a data source", @directory
end
