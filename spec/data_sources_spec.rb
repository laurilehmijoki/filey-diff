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

  context 'when parallelism is disabled' do
    before(:each) {
      @disable_parallel_processing_before = ENV['disable_parallel_processing']
      ENV['disable_parallel_processing'] = 'true'
    }

    after(:each) {
      unless @disable_parallel_processing_before == nil
        ENV['disable_parallel_processing'] = @disable_parallel_processing_before
      end
    }

    it_should_behave_like "a data source", s3_bucket
  end

  context 'gzip' do
    let(:gzip_tempfile_and_path) {
      original_object = objects.first
      [
        gzip_into_tmp_file(original_object[:content], original_object[:mtime]),
        original_object[:path]
      ]
    }

    let(:data_source_with_one_gzipped_object) {
      file, path = gzip_tempfile_and_path
      file.open
      data_source = Filey::DataSources::AwsSdkS3.new(S3Bucket.new([S3Object.new(
        path,
        file.mtime,
        file.read,
        { :content_encoding => 'gzip' }
      )]))
    }

    it 'provides the original md5/mtime of a gzipped file' do
      filey = data_source_with_one_gzipped_object.get_fileys[0]
      filey.md5.should eq(Digest::MD5.hexdigest(objects.first[:content]))
      # GzipWriter seems to cut off fractions of a second,
      # to_i adjusts the original file to match
      filey.last_modified.to_i.should eq(objects.first[:mtime].to_i)
    end

    context 'working with Ruby 2.0.0 automatic decoding of gzipped HTTP responses' do
      let(:data_source_with_decoded_object_and_gzip_header) {
        data_source = Filey::DataSources::AwsSdkS3.new(S3Bucket.new([S3Object.new(
          objects.first[:path],
          objects.first[:mtime],
          objects.first[:content],
          { :content_encoding => 'gzip' }
        )]))
      }

      it 'detects the case where the gzipped data has already been decoded' do
        filey = data_source_with_decoded_object_and_gzip_header.get_fileys.first
        filey.last_modified.should eq(objects.first[:mtime])
      end

      it 'returns the md5 of the gzip-decoded content' do
        filey = data_source_with_decoded_object_and_gzip_header.get_fileys.first
        filey.md5.should eq(Digest::MD5.hexdigest(objects.first[:content]))
      end
    end

    def gzip_into_tmp_file(content, mtime)
      tempfile = Tempfile.new("temp")

      gz = Zlib::GzipWriter.open(tempfile.path, Zlib::BEST_COMPRESSION, Zlib::DEFAULT_STRATEGY)
      gz.mtime = mtime
      gz.write content

      gz.flush
      tempfile.flush

      gz.close
      tempfile
    end
  end
end

describe Filey::DataSources::FileSystem do
  require 'tmpdir'
  @directory = Dir.mktmpdir
  objects.each { |object|
    fs_path = "#{@directory}/#{object[:path]}"
    directory = fs_path.scan(/(.*\/)/).first.first
    FileUtils.mkdir_p directory
    File.open(fs_path, 'w') do |file|
      file.write object[:content]
    end
  }

  it_should_behave_like "a data source", @directory
end
