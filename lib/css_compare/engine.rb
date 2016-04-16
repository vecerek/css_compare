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
      @options[:operands].each { |operand| @operands << CSS::Engine.new(operand).evaluate }
      self
    end

    # Checks, whether the parsed CSS files are equal.
    #
    # The CSS files are equal, if they define the same
    # components, that are also equal and at the same
    # time, no component is missing from either of the
    # files.
    #
    # @return [Boolean]
    def equal?
      @operands.first == @operands.last
    end
  end
end
