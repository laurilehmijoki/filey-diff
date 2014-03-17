Gem::Specification.new do |s|
  s.name              = 'filey-diff'
  s.version           = '1.4.4'

  s.summary     = "Compare two data sources that contain file-like objects"
  s.description =
    """
    Find missing or outdated files.
    For example, compare your local file system to an AWS S3 bucket.
    """

  s.authors  = ["Lauri Lehmijoki"]
  s.email    = 'lauri.lehmijoki@iki.fi'
  s.homepage = 'http://github.com/laurilehmijoki/filey-diff'
  s.license  = 'Apache 2.0'

  s.require_paths = %w[lib]
  s.files         = `git ls-files`.
                      split("\n").
                      # The test files contain UTF8-MAC encoded files. Reject them, as they break the
                      # `rake release` command when run on an UTF8 OS X.
                      reject { |x| x =~ /.*spec.*japanese_files.*/ }
  s.test_files    = `git ls-files -- {test,spec,features}/*`.
                      split("\n").
                      reject { |x| x =~ /.*spec.*japanese_files.*/ }

  s.add_development_dependency 'rake', "~> 0.9"
  s.add_development_dependency 'rspec', "~> 2.11"
end
