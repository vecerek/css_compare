module CssCompare
  module CSS
    module Component
      # Represents a CSS property tied to a specific selector.
      # It can have several values based on the conditions
      # specified by the @media queries.
      class Property
        # @return [String] name of the property
        attr_reader :name

        # Key-value pair of property values.
        #
        # The key represents the condition set by a media query
        # and the value is the actual value of the property.
        #
        # @return [Hash{String=>Value}] name of the property
        attr_accessor :values

        # @note An optimization has been done here, as well.
        #   If there are several conditions, all should be
        #   paired with the same value but not the same object,
        #   since the value can be overridden later in the process
        #   of the stylesheet evaluation. A clone of the value is
        #   paired with each of the conditions.
        #
        # @param [Sass::Tree::PropNode] node the property node
        # @param [Array<String>] conditions media query conditions
        def initialize(node, conditions)
          @name = node.resolved_name
          @values = {}
          value = Value.new(node.resolved_value)
          conditions.each {|c| set_value(value.clone, c)}
        end

        # Merges the property with another one.
        #
        # @param [Property] property to be merged with `self`
        # @return [Void]
        def merge(property)
          property.values.each {|cond, v| set_value(v, cond)}
        end

        # Replaces the original value of the property under a certain
        # media query condition.
        #
        # If the value does not exist under the specified condition,
        # it is added into the set of property values. Otherwise, it
        # rewrites the current value if it's not set as important.
        # However, if the replacing value is also set as important,
        # the current value will be replaced with the new one.
        #
        # If the condition does not exist but there is an important
        # global value assigned to the property, the replacing value
        # will be used only, if it's set to important, too. Otherwise,
        # the global value should be cloned in there.
        #
        # @param [Value] val that should replace the current value
        # @param [String] condition the circumstance, under which
        #   the property should take the new value.
        # @return [Void]
        def set_value(val, condition = 'all')
          global_value = @values['all']
          val_to_replace = value(condition)
          # Check, whether the condition exists
          if val_to_replace
            @values[condition].value = val if val.important? || !val_to_replace.important?
          else
            if global_value && global_value.important?
              @values[condition] = val.important? ? val : global_value.clone
            else
              @values[condition] = val
            end
          end
        end

        # Returns the property's value taken under a certain
        # circumstance
        #
        # @return [#to_s]
        def value(condition = 'all')
          @values[condition]
        end

        # Whether the property is a complex one.
        # One property, that can be separated
        # into smaller chunks of elementary properties.
        #
        # Example:
        #   `border: 1px solid black` => `{
        #       border-width: 1px;
        #       border-style: solid;
        #       border-color: black;
        #   }`
        #
        # @see #process
        # @return [Boolean]
        def is_complex?
          COMPLEX_PROPERTIES.include?(@name)
          false
        end

        # Creates a deep copy of this property.
        #
        # @return [Property]
        def deep_copy
          copy = dup
          copy.values = {}
          @values.each {|k,v| copy.values[k] = v.clone }
          copy
        end

        # Creates the JSON representation of this property.
        #
        # @return [Hash]
        def to_json
          json = {}
          @values.each {|k,v| json[k] = v.to_s }
          json
        end

        private

        COMPLEX_PROPERTIES = []

        # Checks, whether an unprocessed value is important
        # or not
        #
        # @return [Boolean]
        def important_value?(val)
          val.to_s.include?('!important')
        end

        # Breaks down complex properties like `border` into
        # smaller chunks (`border-width`, `border-style`, `border-color`)
        #
        # @return [Array<Property>]
        def process
          return nil unless is_complex?
          []
        end
      end
    end
  end
end