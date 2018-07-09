#!/usr/bin/env ruby
#
# Parser for food ingredient lists.
#
require 'optparse'
require_relative 'ingredients-parser'

begin
  require 'pry'
  def pp(o, color: true)
    if color
      Pry::ColorPrinter.pp(o)
    else
      puts(o.inspect)
    end
  end
rescue loaderror
  # fallback without color printing
  def pp(o, color: nil)
    puts(o.inspect)
  end
end

def colorize(color, s)
  if color
    "\e[#{color}m#{s}\e[0;22m"
  else
    s
  end
end

def parse_single(s, parsed=nil, parser: nil, verbosity: 1, print: nil, escape: false, color: false)
  parser ||= IngredientsParser.new
  parsed ||= parser.parse(s)

  return unless print.nil? || (parsed && print == :parsed) || (!parsed && print == :noresult)

  puts colorize(color && "0;32", escape ? s.gsub("\n", "\\n") : s) if verbosity > 0

  if parsed
    puts(parsed.inspect) if verbosity > 1
    pp(parsed.to_h, color: color) if verbosity > 0
  else
    puts "(no result: #{parser.failure_reason})" if verbosity > 0
  end
end

def parse_file(path, parser: nil, verbosity: 1, print: nil, escape: false, color: false)
  count_parsed = count_noresult = 0
  File.foreach(path) do |line|
    next if line =~ /^#/    # comment
    next if line =~ /^\s*$/ # empty line

    line = line.gsub('\\n', "\n").strip
    parsed = parser.parse(line)
    count_parsed += 1 if parsed
    count_noresult += 1 unless parsed

    parse_single(line, parsed, parser: parser, verbosity: verbosity, print: print, escape: escape, color: color)
  end

  pct_parsed   = 100.0 * count_parsed / (count_parsed + count_noresult)
  pct_noresult = 100.0 * count_noresult / (count_parsed + count_noresult)
  puts "parsed #{colorize(color && "1;32", count_parsed)} (#{pct_parsed.round(1)}%), no result #{colorize(color && "1;31", count_noresult)} (#{pct_noresult.round(1)}%)"
end

verbosity = 1
files = []
strings = []
print = nil
escape = false
color = true
OptionParser.new do |opts|
  opts.banner = <<-EOF.gsub(/^    /, '')
    Usage: #{$0} [options] --file|-f <filename>
           #{$0} [options] --string|-s <ingredients>

  EOF

  opts.on("-f", "--file FILE", "Parse all lines of the file as ingredient lists.") {|f| files << f }
  opts.on("-s", "--string INGREDIENTS", "Parse specified ingredient list.") {|s| strings << s }

  opts.on("-q", "--[no-]quiet", "Only show summary.") {|q| verbosity = q ? 0 : 1 }
  opts.on("-p", "--parsed", "Only show lines that were successfully parsed.") {|p| print = :parsed }
  opts.on("-e", "--escape", "Escape newlines") {|e| escape = true }
  opts.on("-c", "--[no-]color", "Use color") {|e| color = !!e }
  opts.on("-n", "--noresult", "Only show lines that had no result.") {|p| print = :noresult }
  opts.on("-v", "--[no-]verbose", "Show more data (parsed tree).") {|v| verbosity = v ? 2 : 1 }
  opts.on("-h", "--help", "Show this help") do
    puts(opts)
    exit
  end
end.parse!

if strings.any? || files.any?
  parser = IngredientsParser.new
  strings.each {|s| parse_single(s, parser: parser, verbosity: verbosity, print: print, escape: escape, color: color) }
  files.each   {|f| parse_file(f, parser: parser, verbosity: verbosity, print: print, escape: escape, color: color) }
else
  STDERR.puts("Please specify one or more --file or --string arguments (see --help).")
end
