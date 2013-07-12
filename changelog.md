# Changelog

This project is [Semantically Versioned](http://semver.org).

## 1.2.3

* Mention the license in the gemspec file

## 1.2.2

* AwsSdkS3 data source: load S3 objects in slices of 100 when concurrency is
  enabled

## 1.2.1

* Allow disabling of parallel processing with `ENV['disable_parallel_processing'] = 'true'`

## 1.2.0

* Improve performance by loading S3 objects in parallel

## 1.1.2

* Co-operate with Ruby 2.0.0 automatic gzip decoding

## 1.1.1

* Fix dotfiles on Ruby 2.0.0

## 1.1.0

* Add support for gzipped S3 objects

  Thanks to Alex Marchant for implementing this!

## 1.0.2

* Remove the -number suffix from S3 ETags ([thanks
  postmodern!](https://github.com/laurilehmijoki/filey-diff/pull/2))

## 1.0.1

* Support S3 etags that are longer than 32 characters
  [#18](https://github.com/laurilehmijoki/jekyll-s3/issues/18)

## 1.0.0

* Add support for dotfiles (files starting with the '.' character)
* Start using [Semantic Versioning](http://semver.org)
