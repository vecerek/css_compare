module CssCompare
  module CSS
    module Component
      # Represents one simple selector sequence, like
      # .a.b.c > div.f:first-child.
      class Selector
        # @return [String] selector's name
        attr_accessor :name

        # Hash of the selector's properties. Could have been
        # an array but this structure has been chosen, so the
        # properties' lookup gets optimized.
        #
        # @return [Hash{String => Component::Property}] properties
        attr_accessor :properties

        # @param [String] name of the selector
        # @param [Array<Sass::Tree::PropNode>] properties to be included
        # @param [Array<String>] conditions @media query conditions
        def initialize(name, properties, conditions)
          @name = name
          @properties = {}
          process_properties(properties, conditions)
        end

        # Combines the selector's properties with the
        # properties of another selector.
        #
        # If the property does not exist, it will be
        # added. Otherwise the values of the properties
        # will be merged.
        #
        # @see {Property#merge}
        # @param [Property, Array<Property>] properties
        #   one or more properties to be added to the
        #   selector's set of properties.
        # @return [Void]
        def merge(properties)
          if properties.is_a?(Hash)
            properties.each {|_,p| merge(p) }
          else
            name = properties.name
            if @properties[name]
              @properties[name].merge(properties)
            else
              @properties[name] = properties.deep_copy
            end
          end
        end

        # Creates a deep copy of this selector.
        #
        # @param [String] name the new name of
        #   the selector's copy.
        # @return [Selector] a copy of self
        def deep_copy(name = @name)
          copy = dup
          copy.name = name
          copy.properties = {}
          @properties.each {|k,v| copy.properties[k] = v.deep_copy}
          copy
        end

        # Creates the JSON representation of this selector.
        #
        # @return [Hash]
        def to_json
          key = @name.to_sym
          json = {
              key => {}
          }
          @properties.each {|k,v| json[key][k] = v.to_json }
          json
        end

        private

        # Walks through the property nodes ands merges them
        # to the selector's set of properties.
        #
        # @param [Array<Sass::Tree::Node>] properties potential property
        #   nodes of the selector.
        # @param [Array<String>] conditions @media query conditions
        # @return [Void]
        def process_properties(properties, conditions)
          properties.each do |property|
            merge(Property.new(property, conditions)) if property.is_a?(Sass::Tree::PropNode)
          end
        end
      end
    end
  end
end