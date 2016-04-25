module CssCompare
  module CSS
    module Value
      # Wraps the SassScript ListLiteral object.
      class ListLiteral < Base

        # Checks, whether two list literals are equal.
        #
        # @param [ListLiteral] other the other list literal
        # @return [Boolean]
        def ==(other)
          return false unless super
          elements1 = @value.elements.length
          elements2 = other.value.elements.length
          return false unless elements1 == elements2
          @value.elements.each_index do |i|
            value1 = sanitize_string(@value.elements[i].to_sass)
            value2 = sanitize_string(other.value.elements[i].to_sass)
            return false unless value1 == value2
          end
          true
        end
      end
    end
  end
end