module CssCompare
  module Version
    def version
      # =~ http://stackoverflow.com/questions/5781362/ruby-operator
      File.read(CssCompare::Util.scope('VERSION'))
    end
  end

  extend CssCompare::Version

  VERSION = version unless defined?(CssCompare::VERSION)
end