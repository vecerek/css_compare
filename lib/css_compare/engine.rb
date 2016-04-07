require 'css_compare/css'

module CssCompare
  class Engine
    def initialize(options)
      @options = options
      @operands = []
    end

    def parse!
      @options[:operands].each {|operand| @operands << CSS::Parser.new(operand).parse}
    end
  end
end