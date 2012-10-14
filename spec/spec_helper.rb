require 'rubygems'
require 'rspec'
require 'digest/md5'
require File.dirname(__FILE__) + '/../lib/filey-diff'

class S3Object
  attr_reader :key, :last_modified

  def initialize(key, last_modified, content)
    @key = key
    @last_modified = last_modified
    @content = content
  end

  def etag
    Digest::MD5.hexdigest(@content)
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

  def get_fileys
    @file_objects
  end
end
