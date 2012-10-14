$:.unshift File.dirname(__FILE__) # Add the current directory into load path

require 'filey-diff/data-sources/data_source'
require 'filey-diff/data-sources/aws_sdk_s3'
require 'filey-diff/data-sources/file_system'
require 'filey-diff/comparison'
require 'filey-diff/filey'
