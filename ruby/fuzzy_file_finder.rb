#--
# ==================================================================
# Author: Jamis Buck (jamis@jamisbuck.org)
# Date: 2008-10-09
# 
# This file is in the public domain. Usage, modification, and
# redistribution of this file are unrestricted.
# ==================================================================
#++

# The "fuzzy" file finder provides a way for searching a directory
# tree with only a partial name. This is similar to the "cmd-T"
# feature in TextMate (http://macromates.com).
# 
# Usage:
# 
#   finder = FuzzyFileFinder.new
#   finder.search("app/blogcon") do |match|
#     puts match[:highlighted_path]
#   end
#
# In the above example, all files matching "app/blogcon" will be
# yielded to the block. The given pattern is reduced to a regular
# expression internally, so that any file that contains those
# characters in that order (even if there are other characters
# in between) will match.
# 
# In other words, "app/blogcon" would match any of the following
# (parenthesized strings indicate how the match was made):
# 
# * (app)/controllers/(blog)_(con)troller.rb
# * lib/c(ap)_(p)ool/(bl)ue_(o)r_(g)reen_(co)loratio(n)
# * test/(app)/(blog)_(con)troller_test.rb
#
# And so forth.
class FuzzyFileFinder
  module Version
    MAJOR = 1
    MINOR = 0
    TINY  = 0
    STRING = [MAJOR, MINOR, TINY].join(".")
  end

  # This is the exception that is raised if you try to scan a
  # directory tree with too many entries. By default, a ceiling of
  # 10,000 entries is enforced, but you can change that number via
  # the +ceiling+ parameter to FuzzyFileFinder.new.
  class TooManyEntries < RuntimeError; end

  # Used internally to represent a run of characters within a
  # match. This is used to build the highlighted version of
  # a file name.
  class CharacterRun < Struct.new(:string, :inside) #:nodoc:
    def to_s
      if inside
        "(#{string})"
      else
        string
      end
    end
  end

  # Used internally to represent a file within the directory tree.
  class FileSystemEntry #:nodoc:
    attr_reader :name

    def initialize(name)
      @name = name
    end

    def directory?
      false
    end
  end

  # Used internally to represent a subdirectory within the directory
  # tree.
  class Directory < FileSystemEntry
    attr_reader :children

    def initialize(name)
      @children = []
      super
    end

    def directory?
      true
    end
  end

  # The root of the directory tree to search.
  attr_reader :root

  # The maximum number of files and directories (combined).
  attr_reader :ceiling

  # The number of directories beneath +root+
  attr_reader :directory_count

  # The number of files beneath +root+
  attr_reader :file_count

  # Initializes a new FuzzyFileFinder. This will scan the
  # given +directory+, using +ceiling+ as the maximum number
  # of entries to scan. If there are more than +ceiling+ entries
  # a TooManyEntries exception will be raised.
  def initialize(directory=".", ceiling=10_000)
    @root = Directory.new(directory)
    @ceiling = ceiling
    rescan!
  end

  # Rescans the subtree. If the directory contents every change,
  # you'll need to call this to force the finder to be aware of
  # the changes.
  def rescan!
    root.children.clear
    @file_count = 0
    @directory_count = 0
    follow_tree(root.name, root)
  end

  # Takes the given +pattern+ (which must be a string) and searches
  # all files beneath +root+, yielding each match.
  #
  # +pattern+ is interpreted thus:
  #
  # * "foo" : look for any file with the characters 'f', 'o', and 'o'
  #   in its basename (discounting directory names). The characters
  #   must be in that order.
  # * "foo/bar" : look for any file with the characters 'b', 'a',
  #   and 'r' in its basename (discounting directory names). Also,
  #   any successful match must also have at least one directory
  #   element matching the characters 'f', 'o', and 'o' (in that
  #   order.
  # * "foo/bar/baz" : same as "foo/bar", but matching two
  #   directory elements in addition to a file name of "baz".
  #
  # Each yielded match will be a hash containing the following keys:
  #
  # * :path refers to the full path to the file
  # * :directory refers to the directory of the file
  # * :name refers to the name of the file (without directory)
  # * :highlighted_directory refers to the directory of the file with
  #   matches highlighted in parentheses.
  # * :highlighted_name refers to the name of the file with matches
  #   highlighted in parentheses
  # * :highlighted_path refers to the full path of the file with
  #   matches highlighted in parentheses
  # * :abbr refers to an abbreviated form of :highlighted_path, where
  #   path segments without matches are compressed to just their first
  #   character.
  # * :score refers to a value between 0 and 1 indicating how closely
  #   the file matches the given pattern. A score of 1 means the
  #   pattern matches the file exactly.
  def search(pattern, &block)
    pattern.strip!
    path_parts = pattern.split("/")
    path_parts.push "" if pattern[-1,1] == "/"

    file_name_part = path_parts.pop || ""

    if path_parts.any?
      path_regex_raw = "^(.*?)" + path_parts.map { |part| make_pattern(part) }.join("(.*?/.*?)") + "(.*?)$"
      path_regex = Regexp.new(path_regex_raw, Regexp::IGNORECASE)
    end

    file_regex_raw = "^(.*?)" << make_pattern(file_name_part) << "(.*)$"
    file_regex = Regexp.new(file_regex_raw, Regexp::IGNORECASE)

    do_search(path_regex, path_parts.length, file_regex, root, &block)
  end

  # Takes the given +pattern+ (which must be a string, formatted as
  # described in #search), and returns up to +max+ matches in an
  # Array. If +max+ is nil, all matches will be returned.
  def find(pattern, max=nil)
    results = []
    search(pattern) do |match|
      results << match
      break if max && results.length >= max
    end
    return results
  end

  # Displays the finder object in a sane, non-explosive manner.
  def inspect #:nodoc:
    "#<%s:0x%x root=%s, files=%d, directories=%d>" % [self.class.name, object_id, root.name.inspect, file_count, directory_count]
  end

  private

    # Processes the given +path+ into the given +directory+ object,
    # recursively following subdirectories in a depth-first manner.
    def follow_tree(path, directory)
      Dir.entries(path).each do |entry|
        next if entry[0,1] == "."
        raise TooManyEntries if file_count + directory_count > ceiling

        full = path == "." ? entry : File.join(path, entry)
        if File.directory?(full)
          @directory_count += 1
          subdir = Directory.new(full)
          directory.children << subdir
          follow_tree(full, subdir)
        else
          @file_count += 1
          directory.children << FileSystemEntry.new(entry)
        end
      end
    end

    # Takes the given pattern string "foo" and converts it to a new
    # string "(f)([^/]*?)(o)([^/]*?)(o)" that can be used to create
    # a regular expression.
    def make_pattern(pattern)
      pattern = pattern.split(//)
      pattern << "" if pattern.empty?

      pattern.inject("") do |regex, character|
        regex << "([^/]*?)" if regex.length > 0
        regex << "(" << Regexp.escape(character) << ")"
      end
    end

    # Given a MatchData object +match+ and a number of "inside"
    # segments to support, compute both the match score and  the
    # highlighted match string. The "inside segments" refers to how
    # many patterns were matched in this one match. For a file name,
    # this will always be one. For directories, it will be one for
    # each directory segment in the original pattern.
    def build_match_result(match, inside_segments)
      runs = []
      inside_chars = total_chars = 0
      match.captures.each_with_index do |capture, index|
        if capture.length > 0
          # odd-numbered captures are matches inside the pattern.
          # even-numbered captures are matches between the pattern's elements.
          inside = index % 2 != 0

          total_chars += capture.gsub(%r(/), "").length # ignore '/' delimiters
          inside_chars += capture.length if inside

          if runs.last && runs.last.inside == inside
            runs.last.string << capture
          else
            runs << CharacterRun.new(capture, inside)
          end
        end
      end

      # Determine the score of this match.
      # 1. fewer "inside runs" (runs corresponding to the original pattern)
      #    is better.
      # 2. better coverage of the actual path name is better

      inside_runs = runs.select { |r| r.inside }
      run_ratio = inside_runs.length.zero? ? 1 : inside_segments / inside_runs.length.to_f

      char_ratio = total_chars.zero? ? 1 : inside_chars.to_f / total_chars

      score = run_ratio * char_ratio

      return { :score => score, :result => runs.join }
    end

    # Do the actual search, recursively. +path_regex+ is either nil,
    # or a regular expression to match against directory names. The
    # +path_segments+ parameter is an integer indicating how many
    # directory segments there were in the original pattern. The
    # +file_regex+ is a regular expression to match against the file
    # name, +under+ is a Directory object to search. Matches are
    # yielded.
    def do_search(path_regex, path_segments, file_regex, under, &block)
      # If a path_regex is present, match the current directory against
      # it and, if there is a match, compute the score and highlighted
      # result.
      path_match = path_regex && under.name.match(path_regex)

      if path_match
        path_match_result = build_match_result(path_match, path_segments)
        path_match_score = path_match_result[:score]
        path_match_result = path_match_result[:result]
      else
        path_match_score = 1
      end

      # For each child of the directory, search under subdirectories, or
      # match files.
      under.children.each do |entry|
        full = under == root ? entry.name : File.join(under.name, entry.name)
        if entry.directory?
          do_search(path_regex, path_segments, file_regex, entry, &block)
        elsif (path_regex.nil? || path_match) && file_match = entry.name.match(file_regex)
          match_result = build_match_result(file_match, 1)
          highlighted_directory = path_match_result || under.name
          full_match_result = File.join(highlighted_directory, match_result[:result])
          abbr = File.join(highlighted_directory.gsub(/[^\/]+/) { |m| m.index("(") ? m : m[0,1] }, match_result[:result])

          result = { :path => full,
                     :abbr => abbr,
                     :directory => under.name,
                     :name => entry.name,
                     :highlighted_directory => highlighted_directory,
                     :highlighted_name => match_result[:result],
                     :highlighted_path => full_match_result,
                     :score => path_match_score * match_result[:score] }
          yield result
        end
      end
    end
end
