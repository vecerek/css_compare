require 'color'

module CssCompare
  module CSS
    module Value
      # The base class for wrapping the CSS property values
      class Base
        # @return [Sass::Script::Tree::Node]
        attr_accessor :value

        # @param [Sass::Script::Tree::Node] value the SassScript value to be wrapped
        def initialize(value)
          @value = value
        end

        # Checks, whether the CSS values are equal
        #
        # @return [Boolean]
        def ==(other)
          self.class == other.class
        end

        def equals?(other)
          self == other
        end

        # Checks, whether the CSS values are flagged as !important.
        #
        # @return [Boolean]
        def important?
          @value.to_sass.include?('!important')
        end

        # Checks, whether the CSS value is a color. Subclasses may
        # override this method.
        #
        # @return [Boolean]
        def color?
          false
        end

        # @return [String]
        def to_s
          @value.to_sass
        end

        protected

        # Normalizes the quoted string values.
        #
        # @param [String] value the string to sanitize
        # @return [String] sanitized string
        def sanitize_string(value)
          value.sub(/\A['"](.*)['"]\Z/, '\1').gsub(/\\"|"|'/, '"')
        end

        def sanitize_font(value)
          value.gsub(/\\"|"|'/, '')
        end

        # Normalizes the url paths.
        #
        # We can assume, that a value describes a path
        # if following the removal of leading and trailing
        # quotes it begins with a `./`. It can be safely
        # removed without affecting the real value of
        # the CSS property.
        #
        # Examples:
        #   "'path/to/file.css'" #=> "path/to/file.css"
        #   ""\"path/to/file.css\""" #=> ""path/to/file.css""
        #   "./path/to/file.css" #=> "path/to/file.css"
        #
        # @param [String] value the url path to normalize
        # @return [String] the normalized path
        def sanitize_url(value)
          value = sanitize_string(value)
          value = value.sub('./', '') if value.start_with?('./')
          value
        end
      end
    end
  end
end