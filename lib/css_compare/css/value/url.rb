module CssCompare
  module CSS
    module Value
      # Wraps the SassScript `url` Funcall.
      class Url < Base

        # Checks, whether two url calls are equal.
        #
        # @param [Url] other the other url call
        # @return [Boolean]
        def ==(other)
          return false unless super
          value1 = sanitize_url(@value.args[0].value.value)
          value2 = sanitize_url(other.value.args[0].value.value)
          value1 == value2
        end
      end
    end
  end
end