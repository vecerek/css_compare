require 'json'

module CssCompare
  module CSS
    class Parser
      # @param [File]
      def initialize(input)
        @input =  File.expand_path(input)
      end

      # Parses a CSS project
      def parse
        json_ast = JSON.parse(`node #{Util.scope(PARSER)} #{@input}`)
      end

      private

      PARSER = 'lib/css_compare/js/css_parser.js'
    end
  end
end