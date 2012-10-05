require_relative 'spec_helper'

describe Diff::FileObject do
  context 'path validation' do
    it 'requires path to start with a dot and end with a slash' do
      expect {
        Diff::FileObject.new('', 'aliens.txt', Time.now)
      }.to raise_error(Diff::FileObject::InvalidPathError)
    end

    it 'requires path to start with a dot and end with a slash' do
      expect {
        Diff::FileObject.new('.', 'aliens.txt', Time.now)
      }.to raise_error(Diff::FileObject::InvalidPathError)
    end

    it 'requires path to start with a dot and end with a slash' do
      expect {
        Diff::FileObject.new('/', 'aliens.txt', Time.now)
      }.to raise_error(Diff::FileObject::InvalidPathError)
    end

    it 'requires path to start with a dot and end with a slash' do
      Diff::FileObject.new('./ripley/', 'aliens.txt', Time.now)
    end

    it 'requires path to start with a dot and end with a slash' do
      Diff::FileObject.new('./', 'aliens.txt', Time.now)
    end
  end

  context 'time validation' do
    it 'requires the last_modified property to be an instance of Time' do
      expect {
        Diff::FileObject.new('./', 'aliens.txt', '')
      }.to raise_error(Diff::FileObject::InvalidTimeError)
    end

    it 'requires the last_modified property to be an instance of Time' do
      Diff::FileObject.new('./', 'aliens.txt', Time.now)
    end
  end

  context 'name validation' do
    it 'requires the name not to contain slashes' do
      expect {
        Diff::FileObject.new('./', '/aliens.txt', Time.now)
      }.to raise_error(Diff::FileObject::InvalidNameError)
    end

    it 'requires the name not to contain slashes' do
      Diff::FileObject.new('./', 'aliens.txt', Time.now)
    end
  end

  context 'path with name' do
    it 'can concatenate the path and name' do
      Diff::FileObject.new('./ripley/', 'aliens.txt', Time.now).
        full_path.should eq('./ripley/aliens.txt')
    end
  end
end
