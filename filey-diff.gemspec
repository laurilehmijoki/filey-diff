Gem::Specification.new do |s|
  s.name              = 'filey-diff'
  s.version           = '0.0.1'

  s.summary     = "Compare two data sources that contain file-like objects"
  s.description =
    """
    Find missing or outdated files.
    For example, compare your local file system to an AWS S3 bucket.
    """

  s.authors  = ["Lauri Lehmijoki"]
  s.email    = 'lauri.lehmijoki@iki.fi'
  s.homepage = 'http://github.com/laurilehmijoki/filey-diff'

  s.require_paths = %w[lib]
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")

  if RUBY_VERSION < "1.9"
    s.add_dependency 'require_relative', "~> 1.0.3"
  end

  s.add_development_dependency 'rake', "~> 0.9"
  s.add_development_dependency 'rspec', "~> 2.11"
end
