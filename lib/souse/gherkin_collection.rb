require "stringio"
require "gherkin/parser/parser"
require "gherkin/formatter/json_formatter"

module Souse
  class GherkinCollection
    attr_reader :path, :io, :format, :parser
    
    def initialize path
      @path   = path
      @io     = StringIO.new
      @format = Gherkin::Formatter::JSONFormatter.new io
      @parser = Gherkin::Parser::Parser.new format
    end

    def parse_path
      return [path] if path.end_with? ".feature"
      Dir.glob "#{path}/**/*.feature"
    end

    def to_json
      parse_path.each { |f| parser.parse IO.read(f), f, 0 }
      format.done
      MultiJson.load io.string
    end
  end
end
