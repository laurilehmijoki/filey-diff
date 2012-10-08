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
          normalised_path = "./#{path}"
          Filey.new(normalised_path, name, s3_object.last_modified)
        }
      end
    end
  end
end
