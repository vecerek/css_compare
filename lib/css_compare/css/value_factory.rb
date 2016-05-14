require 'css_compare/css/value/base'
require 'css_compare/css/value/literal'
require 'css_compare/css/value/list_literal'
require 'css_compare/css/value/function'
require 'css_compare/css/value/url'

module CssCompare
  module CSS
    module ValueFactory

      # Creates the value object by applying the appropriate wrapper class.
      #
      # @param [Sass::Script::Tree::Node] value the CSS property's value
      # @return [CssCompare::CSS::Value::Base] the wrapped property value
      def self.create(value)
        if value.is_a?(Sass::Script::Tree::Literal)
          Value::Literal.new(value)
        elsif value.is_a?(Sass::Script::Tree::ListLiteral)
          Value::ListLiteral.new(value)
        elsif value.is_a?(Sass::Script::Tree::Funcall)
          return Value::Function.new(value) unless value.name == 'url'
          Value::Url.new(value)
        else
          raise StandardError, 'Unsupported type of CSS value'
        end
      end
    end
  end
end