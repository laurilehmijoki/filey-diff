require 'find'

module Filey
  module DataSources
    class FileSystem
      def initialize(root_directory)
        @root_directory = root_directory
      end

      def get_file_objects
        @cached if @cached
        @cached = Find.find(@root_directory).select { |file|
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
