require "optparse"

module GitCurate

  class CLIParser

    attr_reader :parsed_options

    def initialize
      @parsed_options = {}
    end

    def parse(options)
      opt_parser = OptionParser.new do |opts|
        opts.banner = <<-EOF
  Usage: git curate [options]

  Interactively step through the local branches of the current git repository (other than the current
  branch), printing various information and asking whether to keep or delete each branch.

  Note git-curate does not perform a "git fetch"; if you want to be sure the output reflects the current
  state of any remotes, you should run first run "git fetch" yourself.

  Options:
  EOF

        opts.on(
          "-l",
          "--list",
          "Output information on local branches, including the current one, without stepping through them interactively"
        ) do
          self.parsed_options[:list] = true
        end

        opts.on("-h", "Print this help message") do
          puts opts
          exit
        end

        opts.on("-v", "--version", "Print the currently installed version of this program") do
          puts "git curate v#{GitCurate::VERSION} #{GitCurate::COPYRIGHT}"
          exit
        end
      end

      opt_parser.parse!(options)
    end
  end
end
