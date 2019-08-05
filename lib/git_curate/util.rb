module GitCurate

  module Util

    # Runs the passed string as a system command, gathers any lines of output, stripped of
    # leading and trailing whitespace, and returns them as an array.
    def self.command_to_a(command)
      command_output(command).split($/).map(&:strip)
    end

    # Runs the passed string as a system command and returns its output.
    # If the command doesn't succeed, then an error will be thrown, with the error
    # output as its message.
    def self.command_output(command)
      `#{command}`
    end
  end

end
