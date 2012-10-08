module Filey
  module DataSources
    class DataSource
      def get_fileys
        if @cached
          @cached
        else
          @cached = do_internal_load
        end
      end
    end
  end
end
