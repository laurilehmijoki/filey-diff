module Filey
  class Comparison
    def self.list_outdated(data_source_a, data_source_b)
      select_in_outer_array(data_source_b, data_source_a) { |b_item, a_item|
        b_item.full_path == a_item.full_path and
          b_item.last_modified < a_item.last_modified
      }
    end

    def self.list_changed(data_source_a, data_source_b)
      select_in_outer_array(data_source_b, data_source_a) { |b_item, a_item|
        b_item.full_path == a_item.full_path and
          b_item.md5 != a_item.md5
      }
    end

    def self.list_missing(data_source_a, data_source_b)
      intersection = select_in_outer_array(data_source_a, data_source_b) do
        |a_item, b_item|
        b_item.full_path == a_item.full_path
      end
      data_source_a.get_fileys - intersection
    end

    private

    def self.select_in_outer_array(outer, inner)
      outer.get_fileys.select { |outer_item|
        inner.get_fileys.select { |inner_item|
          yield outer_item, inner_item
        }.length > 0
      }
    end
  end
end
