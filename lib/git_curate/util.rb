require "open3"

module GitCurate

  module Util

    # Runs the passed string as a system command, gathers any lines of output, stripped of
    # leading and trailing whitespace, and returns them as an array.
    def self.command_to_a(command)
      command_output(command).force_encoding('ASCII-8BIT').split($/).map(&:strip)
    end

    # Runs the passed string as a system command and returns its output.
    # If the command doesn't exit with 0 (success), then an error will be thrown, with the error
    # output as its message.
    def self.command_output(command)
      stdout_str, stderr_str, status = Open3.capture3(command)
      exit_status = status.exitstatus

      if exit_status != EXIT_SUCCESS
        raise SystemCommandError.new(stderr_str, exit_status)
      end

      stdout_str
    end
  end

end
