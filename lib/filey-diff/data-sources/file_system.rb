module Filey
  module DataSources
    class FileSystem < DataSource
      def initialize(root_directory)
        @root_directory = root_directory
      end

      private

      def do_internal_load
        Dir.glob(@root_directory + '/**/*').select { |file|
          File.file?(file)
        }.map { |file|
          path = file.scan(/(.*\/).*/).first.first.sub(@root_directory, '')
          name = file.scan(/.*\/(.*)/).first.first
          normalised_path = ".#{path}"
          Filey.new(normalised_path, name, File.mtime(file))
        }
      end
    end
  end
end
