module Diff
  class Comparison
    def self.list_outdated(data_source_a, data_source_b)
      data_source_b.get_file_objects.select { |b_item|
        data_source_a.get_file_objects.select { |a_item|
          b_item.full_path == a_item.full_path and
            b_item.last_modified < a_item.last_modified
        }.length > 0
      }
    end

    def self.list_missing(data_source_a, data_source_b)
      intersection = data_source_a.get_file_objects.select { |a_item|
        data_source_b.get_file_objects.select { |b_item|
          b_item.full_path == a_item.full_path
        }.length > 0
      }
      data_source_a.get_file_objects - intersection
    end
  end
end
