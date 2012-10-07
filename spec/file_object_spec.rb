require_relative 'spec_helper'

describe Filey::FileObject do
  context 'path validation' do
    it 'requires path to start with a dot and end with a slash' do
      expect {
        Filey::FileObject.new('', 'aliens.txt', Time.now)
      }.to raise_error(Filey::FileObject::InvalidPathError)
    end

    it 'requires path to start with a dot and end with a slash' do
      expect {
        Filey::FileObject.new('.', 'aliens.txt', Time.now)
      }.to raise_error(Filey::FileObject::InvalidPathError)
    end

    it 'requires path to start with a dot and end with a slash' do
      expect {
        Filey::FileObject.new('/', 'aliens.txt', Time.now)
      }.to raise_error(Filey::FileObject::InvalidPathError)
    end

    it 'requires path to start with a dot and end with a slash' do
      Filey::FileObject.new('./ripley/', 'aliens.txt', Time.now)
    end

    it 'requires path to start with a dot and end with a slash' do
      Filey::FileObject.new('./', 'aliens.txt', Time.now)
    end
  end

  context 'time validation' do
    it 'requires the last_modified property to be an instance of Time' do
      expect {
        Filey::FileObject.new('./', 'aliens.txt', '')
      }.to raise_error(Filey::FileObject::InvalidTimeError)
    end

    it 'requires the last_modified property to be an instance of Time' do
      Filey::FileObject.new('./', 'aliens.txt', Time.now)
    end
  end

  context 'name validation' do
    it 'requires the name not to contain slashes' do
      expect {
        Filey::FileObject.new('./', '/aliens.txt', Time.now)
      }.to raise_error(Filey::FileObject::InvalidNameError)
    end

    it 'requires the name not to contain slashes' do
      Filey::FileObject.new('./', 'aliens.txt', Time.now)
    end
  end

  context 'path with name' do
    it 'can concatenate the path and name' do
      Filey::FileObject.new('./ripley/', 'aliens.txt', Time.now).
        full_path.should eq('./ripley/aliens.txt')
    end
  end
end
