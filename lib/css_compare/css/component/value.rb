module CssCompare
  module CSS
    module Component
      # Represents the value of a CSS property under
      # certain conditions declared by @media queries.
      class Value < Base
        # @return [CssCompare::CSS::Value::Base]
        attr_accessor :value

        # @param [Sass::Tree::PropNode] val the value of the property
        def initialize(val)
          self.value = val
        end

        # Checks whether two values are equal.
        # Equal values mean, that the actual value and
        # the importance, as well, are set equally.
        #
        # @param [CssCompare::CSS::Value::Base] other the value to compare this with
        # @return [Boolean]
        def ==(other)
          @value == other.value
        end

        # @private
        def value=(val)
          if val.is_a?(self.class)
            @is_important = val.important?
            @value = val.value
          else
            @value = ValueFactory.create(val.value)
            @is_important = @value.important?
          end
        end

        # Tells, whether or not the value is marked as !important
        #
        # @return [Bool]
        def important?
          @is_important
        end

        # @return [String] the String representation of this node
        def to_s
          @value.to_s
        end
      end
    end
  end
end