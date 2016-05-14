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
          if color?
            return false unless other.color?
            ::Color.equivalent?(color, other.color)
          else
            return false unless super
            arg1 = @value.args.length
            arg2 = other.value.args.length
            return false unless arg1 == arg2
            args1 = @value.args.collect { |x| ValueFactory.create(x) }
            args2 = other.value.args.collect { |x| ValueFactory.create(x) }
            args1.each_index { |i| args1[i] == args2[i] }
          end
        end

        # @see Base#color?
        def color?
          rgb? || hsl?
        end

        def color
          raise StandardError, 'Function not a color' unless color?
          args = @value.args.collect { |x| x.value.value }
          if rgb?
            ::Color::RGB.new(args[0], args[1], args[2])
          elsif hsl?
            ::Color::HSL.new(args[0], args[1], args[2])
          end
        end

        def alpha?
          @value.args.length == 4
        end

        def alpha
          return @value.args[3] if alpha?
          false
        end

        private

        RGB_COLOR_FUNCTIONS = %w(rgb rgba)
        HSL_COLOR_FUNCTIONS = %w(hsl hsla)

        def rgb?
          RGB_COLOR_FUNCTIONS.include?(@value.name)
        end

        def hsl?
          HSL_COLOR_FUNCTIONS.include?(@value.name)
        end
      end
    end
  end
end