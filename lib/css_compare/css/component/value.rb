module CssCompare
  module CSS
    module Component
      # Represents a the value of a CSS property under
      # certain conditions declared by @media queries.
      class Value
        # @return [#to_s]
        attr_accessor :value

        # @param [#to_s] val the value of the property
        def initialize(val)
          self.value = val
        end

        # Sets the value and the importance of
        # the {Value} node.
        #
        # @private
        def value=(value)
          original_value = value
          # Can't do gsub! because the String gets frozen and can't be further modified by strip
          value = value.gsub('!important', '')
          @is_important = value != original_value
          @value = value.strip
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
      end
    end
  end
end