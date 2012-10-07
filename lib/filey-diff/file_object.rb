module Filey
  class FileObject
    attr_reader :path, :name, :last_modified

    def initialize(path, name, last_modified)
      raise InvalidPathError unless path.match(/^\..*\/$/)
      raise InvalidTimeError unless last_modified.instance_of?(Time)
      raise InvalidNameError if     name.match(/\//)
      @path = path
      @name = name
      @last_modified = last_modified
    end

    def full_path
      @path + @name
    end

    class InvalidTimeError < Exception
    end

    class InvalidNameError < Exception
    end

    class InvalidPathError < Exception
    end
  end
end
