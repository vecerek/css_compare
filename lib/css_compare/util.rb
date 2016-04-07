module CssCompare
  module Util
    class << self
      # Returns a file's path relative to the Less2Sass root directory.
      #
      # @param file [String] The filename relative to the Less2Sass root
      # @return [String] The filename relative to the the working directory
      def scope(file)
        File.join(CssCompare::ROOT_DIR, file)
      end
    end
  end
end
