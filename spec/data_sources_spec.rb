require File.dirname(__FILE__) + '/spec_helper'
require 'tempfile'
require 'zlib'

shared_examples "a data source" do |source|
  let(:data_source) { described_class.new(source) }

  it 'normalises the objects into Fileys' do
    filey = data_source.get_fileys.sort[0]
    filey.path.should eq('./cameron/80s/')
    filey.name.should eq('aliens.txt')
  end

  it 'provides an md5 hash of the filey content' do
    filey = data_source.get_fileys.sort[0]
    filey.md5.should eq(Digest::MD5.hexdigest('Hudson'))
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

  it 'supports dotfiles' do
    filey = data_source.get_fileys.sort[3]
    filey.path.should eq('./unix/')
    filey.name.should eq('.dotfile')
  end

  it 'normalises the objects into Fileys' do
    data_source.get_fileys.each { |file_object|
      file_object.should be_an_instance_of(Filey::Filey)
    }
  end
end

objects = [
  { :path => 'cameron/80s/aliens.txt', :mtime => Time.now,
    :content => 'Hudson' },
  { :path => 'cameron/90s/t2.txt', :mtime => Time.now,
    :content => 't1000' },
  { :path => 'movies.txt', :mtime => Time.now,
    :content => 'foo' },
  { :path => 'unix/.dotfile', :mtime => Time.now,
    :content => 'I am a dotfile' }
]

describe Filey::DataSources::AwsSdkS3 do
  s3_bucket = S3Bucket.new(
    objects.map { |object|
      S3Object.new(object[:path], object[:mtime], object[:content])
    }
  )
  it_should_behave_like "a data source", s3_bucket

  it 'provides the original md5/mtime of a gzipped file' do
    original_object = objects.first
    tempfile = gzip_into_tmp_file(original_object)
    data_source = s3_data_source_from_file(tempfile, original_object[:path])
    filey = data_source.get_fileys[0]

    filey.md5.should eq(Digest::MD5.hexdigest(original_object[:content]))
    # GzipWriter seems to cut off fractions of a second,
    # to_i adjusts the original file to match
    filey.last_modified.to_i.should eq(original_object[:mtime].to_i)
  end

  def s3_data_source_from_file(file, path)
    file.open
    data_source = Filey::DataSources::AwsSdkS3.new(S3Bucket.new([S3Object.new(
      path,
      file.mtime,
      file.read,
      { :content_encoding => 'gzip' }
    )]))
  end

  def gzip_into_tmp_file(s3_mock_object)
    tempfile = Tempfile.new("temp")

    gz = Zlib::GzipWriter.open(tempfile.path, Zlib::BEST_COMPRESSION, Zlib::DEFAULT_STRATEGY)
    gz.mtime = s3_mock_object[:mtime]
    gz.write s3_mock_object[:content]

    gz.flush
    tempfile.flush

    gz.close
    tempfile
  end
end

describe Filey::DataSources::FileSystem do
  require 'tmpdir'
  @directory = Dir.mktmpdir
  objects.each { |object|
    fs_path = "#{@directory}/#{object[:path]}"
    FileUtils.mkdir_p(fs_path.scan(/(.*\/)/).first.first)
    File.open(fs_path, 'w') do |file|
      file.write object[:content]
    end
  }
  it_should_behave_like "a data source", @directory
end
