require 'digest/md5'

module Filey
  module DataSources
    class FileSystem < DataSource
      def initialize(root_directory, &block)
        @root_directory = root_directory
        @when_filey_loaded = lambda { |filey| block.call filey } if block
      end

      private

      def do_internal_load
        Dir.glob(@root_directory + '/**{,/*/**}/{*,.*}', File::FNM_DOTMATCH).select { |file|
          File.file?(file)
        }.map { |file|
          path = file.scan(/(.*\/).*/).first.first.sub(@root_directory, '')
          name = file.scan(/.*\/(.*)/).first.first
          normalised_path = ".#{path}"
          md5 = Digest::MD5.hexdigest(File.open(file, "rb") { |f| f.read })
          filey = Filey.new(normalised_path, name, File.mtime(file), md5)
          @when_filey_loaded.call(filey) if @when_filey_loaded
          filey
        }
      end
    end
  end
end
