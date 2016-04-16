require 'sass'

module CssCompare
  module CSS
    class Parser
      # @param [File]
      def initialize(input)
        @input = File.expand_path(input)
      end

      # Parses a CSS project using the Sass parser
      #
      # @note The specified syntax is `:scss` because
      #   `:css` has been throwing syntax error on
      #   @charset directive.
      #
      # @return [::Sass::Tree::RootNode]
      def parse
        tree = ::Sass::Engine.new(
          File.read(@input),
          :syntax => :scss, :filename => File.expand_path(@input)
        ).to_tree
        ::Sass::Tree::Visitors::CheckNesting.visit(tree)
        ::Sass::Tree::Visitors::Perform.visit(tree)
      end
    end
  end
end
