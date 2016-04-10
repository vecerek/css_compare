require 'css_compare/css'

module CssCompare
  # The engine responsible for the CSS comparison
  class Engine
    def initialize(options)
      @options = options
      @operands = []
    end

    # Parses and evaluates the input CSS stylesheets - the operands.
    #
    # @return [Engine] itself for method chaining purposes
    def parse!
      @options[:operands].each {|operand| @operands << CSS::Engine.new(operand).evaluate }
      self
    end
  end
end