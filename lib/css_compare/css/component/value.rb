module CssCompare
  module CSS
    module Component
      # Represents the value of a CSS property under
      # certain conditions declared by @media queries.
      class Value < Base
        # @return [#to_s]
        attr_accessor :value

        # @param [#to_s] val the value of the property
        def initialize(val)
          self.value = val
        end

        # Checks whether two values are equal.
        # Equal values mean, that the actual value and
        # the importance, as well, are set equally.
        #
        # @param [Value] other the value to compare this with
        # @return [Boolean]
        def ==(other)
          @value.to_s == other.value.to_s
        end

        # Sets the value and the importance of
        # the {Value} node.
        #
        # @private
        def value=(value)
          original_value = value = value.is_a?(Value) ? value.value : value
          # Can't do gsub! because the String gets frozen and can't be further modified by strip
          value = value.gsub(/\s*!important\s*/, '')
          @is_important = value != original_value
          value = sanitize_value(value) if value =~ CONTAIN_STRING
          @value = value
        end

        # Tells, whether or not the value is marked as !important
        #
        # @return [Bool]
        def important?
          @is_important
        end

        # @return [String] the String representation of this node
        def to_s
          @value.to_s + (@is_important ? ' !important' : '')
        end

        private

        CONTAIN_STRING = /['"](.*)['"]/

        # Normalizes string values.
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
        # @param [String] value the string to sanitize
        # @return [String] sanitized string
        def sanitize_value(value)
          value = value.sub(/\A['"](.*)['"]\Z/, '\1').gsub(/\\"|"|'/, '"') # Solves first two examples
          value = value.sub('./', '') if value.start_with?('url(') # Solves third if it's a url value
          value
        end
      end
    end
  end
end
