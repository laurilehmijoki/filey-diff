module Filey
  module DataSources
    class AwsSdkS3 < DataSource
      def initialize(s3_bucket)
        @s3_bucket = s3_bucket
      end

      private

      def do_internal_load
        @s3_bucket.objects.map { |s3_object|
          if (s3_object.key.include?'/')
            path = s3_object.key.scan(/(.*\/).*/).first.first
            name = s3_object.key.scan(/.*\/(.*)/).first.first
          else
            path = ''
            name = s3_object.key
          end

          last_modified = nil
          if (s3_object.head[:content_encoding] == "gzip")
            tempfile = Tempfile.new(File.basename(path))
            tempfile.write s3_object.read
            tempfile.close

            gz = Zlib::GzipReader.open(tempfile)
            last_modified = gz.mtime
            md5 = Digest::MD5.hexdigest(gz.read)
          else
            last_modified = s3_object.last_modified
            md5 = s3_object.etag.gsub(/"/, '').split('-',2).first
          end
          normalised_path = "./#{path}"
          Filey.new(normalised_path,
                    name,
                    last_modified,
                    md5)
        }
      end
    end
  end
end
