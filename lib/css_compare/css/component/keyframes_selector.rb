module CssCompare
  module CSS
    module Component
      # Represents a rule of the @keyframe directive.
      #
      # Examples:
      #   - from { top: 0; } // also meaning the same as 0%
      #   - 50%  { top: 50; }
      #   - to   { top: 100; } // also meaning the same as 100%
      class KeyframesSelector
        # The value of the rule. Possible values:  <'0%';'100%'>.
        #
        # @return [String]
        attr_reader :value

        # The properties specified at this rule.
        #
        # @return [Hash{String => Property}]
        attr_reader :properties

        # @param [Sass::Tree::KeyframeRuleNode] node a rule node
        #   of the @keyframe directive.
        def initialize(node)
          @value = value(node.resolved_value)
          @properties = {}
          process_properties(node.children)
        end

        # Returns the value represented as percentage, even if
        # declared with the well-known keywords.
        #
        # @return [String] the value of the rule
        def value(value = nil)
          aliases = { :from => '0%', :to => '100%' }
          return  aliases[value.to_sym] || value if value
          @value
        end

        # Adds a new or rewrites an already existing property
        # of this rule's set of properties.
        #
        # @return [Void]
        def add_property(property)
          name = property.name
          if @properties[name]
            @properties[name].merge(property)
          else
            @properties[name] = property
          end
        end

        def deep_copy(value = @value)
          copy = dup
          copy.value = value
          copy.properties = @properties.inject({}) do |result,(k,v)|
            result.update(k => v.deep_copy)
          end
        end

        # Creates the JSON representation of this keyframes
        # selector.
        #
        # @return [Hash]
        def to_json
          @properties.inject({}) do |result, (name,prop)|
            result.update(name.to_sym => prop.to_json)
          end
        end

        # Creates and puts te properties into the set of
        # properties of this rule.
        #
        # @return [Void]
        def process_properties(properties)
          properties.each do |prop|
            add_property(Property.new(prop, ['no condition'])) if prop.is_a?(Sass::Tree::PropNode)
          end
        end
      end
    end
  end
end