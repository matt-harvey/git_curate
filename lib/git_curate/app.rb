require "optparse"

module GitCurate

  module App

    def self.main
      parser = GitCurate::CLIParser.new
      continue = parser.parse(ARGV) # will throw on error
      return 0 unless continue

      runner = GitCurate::Runner.new(parser.parsed_options)
      runner.run(ARGV)
    rescue OptionParser::InvalidOption
      puts "Unrecognized option"
      puts "For help, enter `git curate -h`"
      1
    end

  end

end
