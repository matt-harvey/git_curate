require "optparse"

module GitCurate

  module App

    # Runs the application and returns an exit status which should be passed to exit() by
    # the caller of this function.
    def self.main
      parser = GitCurate::CLIParser.new
      continue = parser.parse(ARGV) # will throw on error
      return EXIT_SUCCESS unless continue

      runner = GitCurate::Runner.new(parser.parsed_options)
      runner.run(ARGV)
    rescue SystemCommandError => error
      $stderr.puts(error.message)
      error.exit_status
    rescue OptionParser::InvalidOption
      puts "Unrecognized option"
      puts "For help, enter `git curate -h`"
      EXIT_FAILURE
    end

  end

end
