# frozen_string_literal: true

module KFileset
  # FileSet will build up a list of files and/or folders that match a whitelist.
  #
  # Path <PathEntry> will point to a real file or folder
  #
  # That list of files can be filtered using exclusions that
  # follow either Glob or Regex patterns.
  #
  # Resources:
  #   - Rake-FileList: https://github.dev/ruby/rake/blob/5c60da8644a9e4f655e819252e3b6ca77f42b7af/lib/rake/file_list.rb
  #   - Glob vs Regex: https://www.linuxjournal.com/content/globbing-and-regex-so-similar-so-different
  #   - Glob patterns: http://web.mit.edu/racket_v612/amd64_ubuntu1404/racket/doc/file/glob.html
  #   require 'rake/file_list'
  #   Rake::FileList['**/*'].exclude(*File.read('.gitignore').split)
  class FileSet
    DEF_FLAGS = File::FNM_PATHNAME | File::FNM_EXTGLOB
    DEF_FLAGS_DOTMATCH = File::FNM_PATHNAME | File::FNM_EXTGLOB | File::FNM_DOTMATCH

    DEFAULT_IGNORE_PATTERNS = [
      %r{(^|[/\\])CVS([/\\]|$)},
      %r{(^|[/\\])\.svn([/\\]|$)},
      /\.bak$/,
      /~$/
    ].freeze

    IGNORE_LAMBDAS = {
      # Match Examples: 'target/deep/a', 'target/deep/a/.', 'target/deep/a/b', 'target/deep/a/b/.'
      folder: ->(path) { File.directory?(path) },

      # Match Examples: 'target/deep/a', 'target/deep/a/b'
      folder_current: ->(path) { File.directory?(path) && !path.end_with?('.') },

      # Match Examples: 'target/deep/a/.', 'target/deep/a/b/.'
      folder_current_dot: ->(path) { File.directory?(path) && path.end_with?('.') }
    }.freeze

    # proc { |fn| fn =~ /(^|[\/\\])core$/ && !File.directory?(fn) }
    DEFAULT_IGNORE_LAMBDAS = [
      IGNORE_LAMBDAS[:folder]
    ].freeze

    # Expression to detect standard file GLOB pattern
    GLOB_PATTERN = /[*?\[{]/.freeze

    attr_writer :file_set # paths / resources / path_entries / valid_resources
    attr_reader :whitelist # whitelist (rules)

    # FileSet will build up a list of files and/or folders that match a whitelist.

    # attr_writer :items # paths / resources / path_entries / valid_resources
    # attr_writer :paths # paths / resources / path_entries / valid_resources
    # attr_writer :entries # paths / resources / path_entries / valid_resources
    # attr_writer :path_entries # paths / resources / path_entries / valid_resources
    # attr_writer :resource # paths / resources / path_entries / valid_resources

    # attr_reader :whitelist_rules # whitelist (rules)
    # attr_reader :whitelist_files # whitelist (rules)

    def initialize
      @dirty = false
      @whitelist = KFileset::Whitelist.new
      @file_set = {}
    end

    # Add a Glob with option exclusions to the whitelist
    #
    # @param [String] glob Any Bourne/Bash shell Glob pattern is acceptable
    # @param [String|Regex|Array] exclude Glob Pattern or Regexp or Array of patterns to exclude.
    # @param [String] exclude Glob Pattern
    # @param [RegExp] exclude Regular expression
    # @param [Array<String, Regex>] exclude List of Glob patterns or Regular expressions
    def glob(glob, exclude: nil, flags: DEF_FLAGS, use_defaults: true)
      exclude = add_default_exclusions(exclude, use_defaults)
      @whitelist.add(glob, exclude, flags)
      @dirty = true

      self
    end

    # Add absolute file
    def add(path)
      path = Pathname.new(path).realpath
      return if file_set.key?(path)
      return unless whitelist.match?(file)

      file_set.add(file)
    end

    def clear
      @dirty = true
      @file_set.clear
      @whitelist.clear
    end

    def length
      file_set.length
    end

    # def valid?(file)
    #   return true if files.include?(file)

    #   if new_file_match?(file)
    #     @file_set.add(file)
    #     return true
    #   end

    #   false
    # end

    def path_entries
      @path_entries ||= file_set.values.sort_by(&:key)
    end

    def relative_paths
      path_entries.map(&:to_path) # relative_path }
    end

    def absolute_paths
      path_entries.map { |entry| entry.realpath.to_s }
    end

    def pwd
      Dir.pwd
    end

    def remove(path)
      path = abs_path(path)
      file_set.delete(path)
    end

    def debug
      path_entries.each(&:debug)
    end

    private

    def abs_path(path)
      Pathname.new(path).realpath.to_s
    end

    # renamed to path_entries | .paths
    def file_set
      return @file_set unless @dirty

      @dirty = false
      whitelist.path_entries.each do |path_entry|
        # puts path_entry.class
        # puts path_entry.key.class
        # puts path_entry.key
        @file_set[path_entry.key] = path_entry
      end
      @file_set
      # @file_set = @file_set.merge()
    end

    def add_default_exclusions(exclude, use_defaults)
      result = []

      result += DEFAULT_IGNORE_PATTERNS if use_defaults
      result += DEFAULT_IGNORE_LAMBDAS if use_defaults

      return result unless exclude
      return result + exclude if exclude.is_a?(Array)

      result << exclude

      result
    end

    # def new_file_match?(file)
    #   whitelist.any? { |white_entry| white_entry.match?(file) }
    # end

    # def exclude_files(glob, exclude = nil)
    #   get_files = Dir[glob]

    #   return get_files unless exclude

    #   return get_files.reject { |file| exclude.any? { |pattern| pattern_match?(pattern, file) } } if exclude.is_a?(Array)

    #   get_files.reject { |file| pattern_match?(exclude, file) }
    # end

    # def pattern_match?(pattern, file)
    #   return pattern.match?(file) if pattern.is_a?(Regexp)

    #   # Guard
    #   return false unless pattern.is_a?(String)

    #   File.fnmatch?(pattern, file) # As String
    # end
  end
end
