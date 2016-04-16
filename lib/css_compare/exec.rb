require 'css_compare/engine'
require 'optparse'

module CssCompare
  class Comparison
    def initialize(args)
      @args = args
      @options = {}
    end

    # Parses the command-line arguments and runs the executable.
    # Calls `Kernel#exit` at the end, so it never returns.
    #
    # @see #parse
    def parse!
      begin
        parse
      rescue Exception => e
        raise e if @options[:trace] || e.is_a?(SystemExit)
        $stderr.puts "#{e.class}: " + e.message.to_s
        exit 1
      end
      exit 0
    end

    # Parses the command-line arguments and runs the executable.
    def parse
      OptionParser.new do |opts|
        set_opts(opts)
      end.parse!(@args)

      process_args

      @options
    end

    protected

    # Tells optparse how to parse the arguments.
    #
    # @param opts [OptionParser]
    def set_opts(opts)
      opts.banner = <<END
Usage: css_compare [options] CSS_1 CSS_2
Description:
Compares two CSS files/projects and tells whether they are equal.
END

      common_options(opts)
      input_and_output(opts)
    end

    def common_options(opts)
      opts.on('-?', '-h', '--help', 'Show this help message.') do
        puts opts
        exit
      end

      opts.on('-v', '--version', 'Print the Sass version.') do
        puts("Less2Sass #{CssCompare.version[:string]}")
        exit
      end
    end

    # @todo: specify an option for outputting the diff, when feature is ready
    def input_and_output(opts)
      # opts.separator ''
      # opts.separator 'Input and Output:'
    end

    def open_file(filename, flag = 'r')
      return if filename.nil?
      File.open(filename, flag)
    end

    # Processes the options set by the command-line arguments -
    # `@options[:input]` and `@options[:output]` are being set
    # to appropriate IO streams.
    #
    # This method is being overridden by subclasses
    # to run their respective programs.
    def process_args
      args = @args.dup
      @options[:operands] = nil
      if args.length >= 2
        @options[:operands] = args.shift(2)
      else
        raise ArgumentError, "You have specified #{args.length} operand(s), 2 expected."
      end
      @options[:output_filename] = args.shift unless args.empty?
      @options[:output] ||= @options[:output_filename] || $stdout

      run
    end

    # Runs the comparison.
    def run
      result = CssCompare::Engine.new(@options)
                                 .parse!
                                 .equal?
      puts result.to_s
    end
  end
end
