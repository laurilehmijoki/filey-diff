module Filey
  class Filey
    attr_reader :path, :name, :last_modified, :md5

    def initialize(path, name, last_modified, md5)
      raise InvalidPathError unless path.match(/^\..*\/$/)
      raise InvalidTimeError unless last_modified.instance_of?(Time)
      raise InvalidNameError if     name.match(/\//)
      raise InvalidMd5Error  unless md5.length == 32
      @path = path
      @name = name
      @last_modified = last_modified
      @md5 = md5
    end

    def full_path
      @path + @name
    end

    def <=> (another)
      full_path <=> another.full_path
    end

    class InvalidTimeError < Exception
    end

    class InvalidNameError < Exception
    end

    class InvalidPathError < Exception
    end

    class InvalidMd5Error < Exception
    end
  end
end
