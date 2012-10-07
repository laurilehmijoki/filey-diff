require File.dirname(__FILE__) + '/spec_helper'

describe Filey::Filey do
  context 'path validation' do
    it 'requires path to start with a dot and end with a slash' do
      expect {
        Filey::Filey.new('', 'aliens.txt', Time.now)
      }.to raise_error(Filey::Filey::InvalidPathError)
    end

    it 'requires path to start with a dot and end with a slash' do
      expect {
        Filey::Filey.new('.', 'aliens.txt', Time.now)
      }.to raise_error(Filey::Filey::InvalidPathError)
    end

    it 'requires path to start with a dot and end with a slash' do
      expect {
        Filey::Filey.new('/', 'aliens.txt', Time.now)
      }.to raise_error(Filey::Filey::InvalidPathError)
    end

    it 'requires path to start with a dot and end with a slash' do
      Filey::Filey.new('./ripley/', 'aliens.txt', Time.now)
    end

    it 'requires path to start with a dot and end with a slash' do
      Filey::Filey.new('./', 'aliens.txt', Time.now)
    end
  end

  context 'time validation' do
    it 'requires the last_modified property to be an instance of Time' do
      expect {
        Filey::Filey.new('./', 'aliens.txt', '')
      }.to raise_error(Filey::Filey::InvalidTimeError)
    end

    it 'requires the last_modified property to be an instance of Time' do
      Filey::Filey.new('./', 'aliens.txt', Time.now)
    end
  end

  context 'name validation' do
    it 'requires the name not to contain slashes' do
      expect {
        Filey::Filey.new('./', '/aliens.txt', Time.now)
      }.to raise_error(Filey::Filey::InvalidNameError)
    end

    it 'requires the name not to contain slashes' do
      Filey::Filey.new('./', 'aliens.txt', Time.now)
    end
  end

  context 'path with name' do
    it 'can concatenate the path and name' do
      Filey::Filey.new('./ripley/', 'aliens.txt', Time.now).
        full_path.should eq('./ripley/aliens.txt')
    end
  end
end
