require 'rubygems'
require 'require_relative' if RUBY_VERSION < "1.9"
require_relative 'filey-diff/data-sources/data_source'
require_relative 'filey-diff/data-sources/aws_sdk_s3'
require_relative 'filey-diff/data-sources/file_system'
require_relative 'filey-diff/filey'
require_relative 'filey-diff/comparison'
