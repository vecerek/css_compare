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
      rescue StandardError => e
        raise e if @options[:trace] || e.is_a?(SystemExit)
        $stderr.puts "#{e.class}: " + e.message.to_s
        exit 1
      end
      exit 0
    end

    # Parses the command-line arguments and runs the executable.
    def parse
      @opts = OptionParser.new { |opts| process_opts(opts) }
      @opts.parse!(@args)

      process_args

      @options
    end

    protected

    # Tells optparse how to parse the arguments.
    #
    # @param opts [OptionParser]
    def process_opts(opts)
      opts.banner = <<END
Usage: css_compare <CSS file> <CSS file>
Description:
Checks the equality of
END

      common_options(opts)
      input_and_output(opts)
    end

    def common_options(opts)
      opts.on('-?', '-h', '--help', 'Show this help message.') do
        puts opts
        exit
      end

      opts.on('-v', '--version', 'Print the css_compare version.') do
        puts("v#{CssCompare::VERSION}")
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
      unless args.length >= 2
        puts @opts
        exit 1
      end
      @options[:operands] = args.shift(2)
      @options[:output_filename] = args.shift unless args.empty?
      @options[:output] ||= @options[:output_filename] || $stdout

      run
    end

    def write_output(text, destination)
      if destination.is_a?(String)
        open_file(destination, 'w') { |file| file.write(text) }
      else
        destination.write(text)
      end
    end

    # Runs the comparison.
    def run
      result = CssCompare::Engine.new(@options)
                                 .parse!
                                 .equal?
      write_output(result.to_s + "\n", @options[:output])
    end
  end
end
