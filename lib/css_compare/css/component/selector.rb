module CssCompare
  module CSS
    module Component
      # Represents one simple selector sequence, like
      # .a.b.c > div.f:first-child.
      #
      # @see https://www.w3.org/TR/css3-selectors/#selectors
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
        # @param [Property, Array<Property>] other
        #   the selector to be merged with
        # @return [Void]
        def merge(other)
          other.properties.each do |_,prop|
            add_property(prop)
          end
        end

        # Adds a property to the existing set of properties
        # of this selector.
        #
        # If the property does not exist, it will be
        # added. Otherwise the values of the properties
        # will be merged.
        #
        # @see {Property#merge}
        # @param [Property] prop the property to add
        # @param [Boolean] deep_copy tells, whether a
        #   deep copy should be applied onto the property.
        # @return [Void]
        def add_property(prop, deep_copy = true)
          name = prop.name
          if @properties[name]
            @properties[name].merge(prop)
          else
            if deep_copy
              @properties[name] = prop.deep_copy
            else
              @properties[name] = prop
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
          json = { key => {} }
          @properties.inject(json[key]) do |result, (k,v)|
            result.update(k => v.to_json)
          end
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
            add_property(Property.new(property, conditions)) if property.is_a?(Sass::Tree::PropNode)
          end
        end
      end
    end
  end
end