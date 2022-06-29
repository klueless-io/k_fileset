# frozen_string_literal: true

require 'k_log'
require 'k_fileset/version'
require 'k_fileset/whitelist'
require 'k_fileset/path_entry'
require 'k_fileset/glob_props'
require 'k_fileset/glob_entry'
require 'k_fileset/glob_info'
require 'k_fileset/file_set'

module KFileset
  # raise KFileset::Error, 'Sample message'
  class Error < StandardError; end

  # Your code goes here...
end

if ENV.fetch('KLUE_DEBUG', 'false').downcase == 'true'
  namespace = 'KFileset::Version'
  file_path = $LOADED_FEATURES.find { |f| f.include?('k_fileset/version') }
  version = KFileset::VERSION.ljust(9)
  puts "#{namespace.ljust(35)} : #{version.ljust(9)} : #{file_path}"
end
