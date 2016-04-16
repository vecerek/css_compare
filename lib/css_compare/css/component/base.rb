module CssCompare
  module CSS
    module Component
      class Base
        # Checks, whether two hashes are equal.
        #
        # They are equal, if they contain the same keys
        # and also have the same values assigned.
        #
        # @param [Hash] this first hash to compare
        # @param [Hash] that second hash to compare
        # @return [Boolean]
        def ==(this, that)
          keys = this.keys + that.keys
          keys.uniq!
          keys.all? { |key| this[key] && that[key] && this[key] == that[key] }
        end
      end
    end
  end
end
