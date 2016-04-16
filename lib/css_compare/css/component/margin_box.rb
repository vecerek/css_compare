module CssCompare
  module CSS
    module Component
      # Represents a @page's margin box declaration.
      # A page margin box consists of a margin symbol, like
      # `@top-left-corner` and a list of declarations.
      #
      # MarginBox inherits from the Selector class, since
      # there are inevitable similarities. The specified margin
      # symbol can be reached by the `value` property of the
      # instance of this class.
      #
      # @see Selector
      class MarginBox < Selector
        IGNORED_CONDITIONS = %w(width height aspect-ratio orientation).freeze

        # Looks for a `size` property to delete the values
        # that should be ignored according to the @page
        # W3 specification.
        #
        # If a size property declaration is qualified by a
        # ‘width’, ‘height’, ‘device-width’, ‘device-height’,
        # ‘aspect-ratio’, ‘device-aspect-ratio’ or ‘orientation’
        # media query (or other conditional on the size of the
        # paper), then the declaration must be ignored.
        #
        # @see https://www.w3.org/TR/css3-page/#page-size
        #   ISSUE 3 and EXAMPLE 23
        #
        # @see Property#add_property
        def add_property(prop, deep_copy = false)
          prop.values.delete_if do |k, _|
            IGNORED_CONDITIONS.any? { |condition| k.include?(condition) }
          end if prop.name === 'size'
          super(prop, deep_copy)
        end
      end
    end
  end
end
