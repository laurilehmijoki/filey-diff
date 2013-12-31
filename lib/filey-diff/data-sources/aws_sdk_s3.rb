module Filey
  module DataSources
    class AwsSdkS3 < DataSource
      def initialize(s3_bucket, config = { :concurrency_level => DEFAULT_CONCURRENCY_LEVEL }, &block)
        @s3_bucket = s3_bucket
        @config = config
        @when_filey_loaded = lambda { |filey| block.call filey } if block
      end

      private

      DEFAULT_CONCURRENCY_LEVEL = 3

      def do_internal_load
        fileys = []
        map_to_filey = lambda { |s3_object|
          fileys << map_s3_object_to_filey(s3_object)
        }
        in_parallel_or_sequentially map_to_filey
        fileys
      end

      def in_parallel_or_sequentially(operation_on_s3_object)
        jobs = @s3_bucket.objects.map { |s3_object|
          lambda {
            operation_on_s3_object.call s3_object
          }
        }
        if ENV['disable_parallel_processing']
          jobs.each(&:call)
        else
          jobs.each_slice(slice_size) { |jobs|
            threads = jobs.map { |job|
              Thread.new {
                job.call
              }
            }
            threads.each(&:join)
          }
        end
      end

      def slice_size
        slice_size_from_cfg = @config[:concurrency_level] || @config['concurrency_level']
        slice_size_from_cfg || DEFAULT_CONCURRENCY_LEVEL
      end

      def map_s3_object_to_filey(s3_object)
        if (s3_object.key.include?'/')
          path = s3_object.key.scan(/(.*\/).*/).first.first
          name = s3_object.key.scan(/.*\/(.*)/).first.first
        else
          path = ''
          name = s3_object.key
        end

        if (s3_object.head[:content_encoding] == "gzip")
          last_modified, md5 = last_modified_and_md5_from_gzipped(
            s3_object, path
          )
        else
          last_modified, md5 = last_modified_and_md5(s3_object)
        end

        normalised_path = "./#{path}"
        filey = Filey.new(
          normalised_path,
          name,
          last_modified,
          md5
        )
        @when_filey_loaded.call(filey) if @when_filey_loaded
        filey
      end

      def last_modified_and_md5(s3_object)
        last_modified = s3_object.last_modified
        md5 = s3_object.etag.gsub(/"/, '').split('-',2).first
        [last_modified, md5]
      end

      def last_modified_and_md5_from_gzipped(s3_object, path)
        s3_object_contents = s3_object.read
        if is_already_decoded s3_object_contents
          md5 = Digest::MD5.hexdigest(s3_object_contents)
          [s3_object.last_modified, md5]
        else
          tempfile = Tempfile.new(File.basename(path))
          tempfile.binmode
          tempfile.write s3_object_contents
          tempfile.close

          gz = Zlib::GzipReader.open(tempfile.path)
          last_modified = gz.mtime
          md5 = Digest::MD5.hexdigest(gz.read)
          gz.close
          [last_modified, md5]
        end
      end

      # Check if the two first bytes are the magic numbers of the gzip format.
      # We double-check here because Ruby 2.0.0 decodes gzip'ed HTTP responses
      # automatically. As a result, we get decoded gzip data from the
      # s3_object#read method when we are using Ruby 2.0.0, and encoded data
      # when we are using previous versions of Ruby.
      def is_already_decoded(gzipped_on_server)
        is_gzipped = gzipped_on_server.bytes.to_a[0] == 0x1f && gzipped_on_server.bytes.to_a[1] == 0x8b
        is_gzipped == false
      end
    end
  end
end
