require "open3"

module GitCurate

  module Util

    # Runs the passed string as a system command, gathers any lines of output, stripped of
    # leading and trailing whitespace, and returns them as an array.
    def self.command_to_a(command)
      command_output(command).split($/).map(&:strip)
    end

    # Runs the passed string as a system command and returns its output.
    def self.command_output(command)
      Open3.capture2(command).first
    end

  end

end
