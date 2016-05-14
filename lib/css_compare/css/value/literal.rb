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
          if color?
            return false unless other.color?
            ::Color.equivalent?(color, other.color)
          else
            return false unless super
            value1 = sanitize_string(@value.to_sass)
            value2 = sanitize_string(other.value.to_sass)
            value1 == value2
          end
        end

        def equals?(other)
          value1 = sanitize_font(@value.to_sass)
          value2 = sanitize_font(other.value.to_sass)
          value1 == value2
        end

        def color?
          named_color? || hex_color?
        end

        def color
          return nil unless color?
          hex_color? ? hex_color : named_color
        end

        private

        HEX_COLOR_LITERAL = /^#(?:[a-f0-9]{3}){1,2}$/i

        def named_color?
          ::Color::CSS[@value.to_sass]
        end

        alias_method :named_color, :named_color?

        def hex_color?
          @value.to_sass =~ HEX_COLOR_LITERAL
        end

        def hex_color
          ::Color::RGB.by_hex(@value.to_sass)
        end
      end
    end
  end
end