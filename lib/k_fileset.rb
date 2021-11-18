# frozen_string_literal: true

require 'k_fileset/version'

module KFileset
  # raise KFileset::Error, 'Sample message'
  class Error < StandardError; end

  # Your code goes here...
end

if ENV['KLUE_DEBUG']&.to_s&.downcase == 'true'
  namespace = 'KFileset::Version'
  file_path = $LOADED_FEATURES.find { |f| f.include?('k_fileset/version') }
  version = KFileset::VERSION.ljust(9)
  puts "#{namespace.ljust(35)} : #{version.ljust(9)} : #{file_path}"
end
