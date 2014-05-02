module Filey
  class Comparison
    def self.list_outdated(data_source_a, data_source_b)
      select_in_outer_array(data_source_b, data_source_a) { |b_item, a_item|
        !a_item.nil? && b_item.last_modified < a_item.last_modified
      }
    end

    def self.list_changed(data_source_a, data_source_b)
      select_in_outer_array(data_source_b, data_source_a) { |b_item, a_item|
        !a_item.nil? && b_item.md5 != a_item.md5
      }
    end

    def self.list_missing(data_source_a, data_source_b)
      intersection = select_in_outer_array(data_source_a, data_source_b) { |a_item, b_item|
        !b_item.nil?
      }
      data_source_a.get_fileys - intersection
    end

    private

    def self.select_in_outer_array(outer, inner)
      inner_hash = inner.get_fileys.reduce({}) { |h, e| h[e.full_path] = e; h }
      outer.get_fileys.select { |outer_item|
        yield outer_item, inner_hash[outer_item.full_path]
      }
    end
  end
end
