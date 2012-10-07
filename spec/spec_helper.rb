require 'rspec'
require File.dirname(__FILE__) + '/../lib/filey-diff'

class S3Object
  attr_reader :key, :last_modified

  def initialize(key, last_modified)
    @key = key
    @last_modified = last_modified
  end
end

class S3Bucket
  attr_reader :objects

  def initialize(s3_objects)
    @objects = s3_objects
  end
end

class DataSource
  def initialize(file_objects)
    @file_objects = file_objects
  end

  def get_file_objects
    @file_objects
  end
end
