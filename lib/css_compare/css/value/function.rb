module CssCompare
  module CSS
    module Value
      # Wraps the SassScript Funcall object
      class Function < Base

        # Checks, whether two function expressions are equal.
        #
        # @param [Function] other the other function expression
        # @return [Boolean]
        def ==(other)
          return false unless super
          arg1 = @value.args.length
          arg2 = other.value.args.length
          return false unless arg1 == arg2
          @value.args.each_index do |i|
            value1 = @value.args[i].value.to_sass
            value2 = other.value.args[i].value.to_sass
            return false unless value1 == value2
          end
          true
        end
      end
    end
  end
end