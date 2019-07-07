module GitCurate

  class Branch

    attr_reader :raw_name

    # raw_name should start in "* " if the current branch, but should otherwise have not whitespace.
    def initialize(raw_name)
      @raw_name = raw_name
    end

    def proper_name
      @proper_name ||= @raw_name.lstrip.gsub(/^\*\s+/, '')
    end

    def current?
      @current ||= /^\*\s+/.match?(@raw_name)
    end

    def displayable_name(pad:)
      if pad && !current?
        "  #{@raw_name}"
      else
        @raw_name
      end
    end

    def last_author
      `git log -n1 --format=format:%an #{proper_name}`
    end

    def last_commit_date
      `git log -n1 --date=short --format=format:%cd #{proper_name}`
    end

    def last_subject
      `git log -n1 --format=format:%s #{proper_name}`
    end

  end

end