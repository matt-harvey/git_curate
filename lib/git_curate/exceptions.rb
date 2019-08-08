module GitCurate

  EXIT_SUCCESS = 0
  EXIT_FAILURE = 1

  # Error indicating that a system command has exited with a non-success exit status.
  class SystemCommandError < StandardError

    attr_reader :exit_status

    def initialize(message, exit_status)
      super(message)
      @exit_status = exit_status
    end
  end
end
