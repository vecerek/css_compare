module CssCompare
  module CSS
    module Value
      # Wraps the SassScript Literal object.
      class Literal < Base

        # Checks, whether two literals are equal.
        #
        # @param [Literal] other the other literal
        # @return [Boolean]
        def ==(other)
          return false unless super
          value1 = sanitize_string(@value.to_sass)
          value2 = sanitize_string(other.value.to_sass)
          value1 == value2
        end
      end
    end
  end
end