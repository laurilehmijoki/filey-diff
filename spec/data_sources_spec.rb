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

  context '#initialize' do
    it 'takes a block and dispatches every new filey to the block' do
      called_upon_fileys = []
      data_source = described_class.new(source) { |filey|
        called_upon_fileys << filey
      }
      resulting_fileys = data_source.get_fileys
      called_upon_fileys.empty?.should be(false)
      resulting_fileys.should eq(called_upon_fileys)
    end
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

  context '#in_parallel_or_sequentially' do

    shared_examples 'concurrent processing' do |concurrency_level, config|
      let(:operation_on_s3_object) {
        @ints = []
        operation_on_s3_object = lambda do |s3_object|
          @ints << s3_object
        end
      }

      before(:each) {
        s3_bucket = double(
          's3_bucket',
          :objects => (0..200).map { |int| int }
      )
        data_source = Filey::DataSources::AwsSdkS3.new(s3_bucket, config)
        data_source.send(:in_parallel_or_sequentially, operation_on_s3_object)
      }

      it "honors the concurrency level by processing the first #{concurrency_level} items first" do
        @ints.take(concurrency_level).all? { |int|
          int <= concurrency_level
        }.should be true
      end

      it "honors the concurrency level by processing the second patch of #{concurrency_level} items second" do
        @ints.drop(concurrency_level).take(concurrency_level).all? { |int|
          int >= concurrency_level && int < (2 * concurrency_level)
        }.should be true
      end
    end

    describe 'default concurrency level' do
      concurrency_level = Filey::DataSources::AwsSdkS3::DEFAULT_CONCURRENCY_LEVEL

      include_examples(
        'concurrent processing',
        concurrency_level,
        nil
      )
    end

    describe 'specifying custom concurrency level' do
      concurrency_level = 20
      include_examples(
        'concurrent processing',
        concurrency_level,
        { :concurrency_level => concurrency_level }
      )
    end
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

    it 'provides the md5/mtime of a gzipped file' do
      filey = data_source_with_one_gzipped_object.get_fileys[0]
      gzipped_content = IO.binread(gzip_tempfile_and_path[0])
      filey.md5.should eq(Digest::MD5.hexdigest(gzipped_content))
      # GzipWriter seems to cut off fractions of a second,
      # to_i adjusts the original file to match
      filey.last_modified.to_i.should eq(objects.first[:mtime].to_i)
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
