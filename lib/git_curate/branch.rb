module GitCurate

  class Branch

    # Regex for determining whether a "raw" branch name is the name of the current branch
    CURRENT_BRANCH_REGEX = /^\*\s+/

    # Regexes for unpacking the output of `git branch -vv`
    BRANCH_NAME_REGEX = /\s+/
    LEADING_STAR_REGEX = /^\* /
    REMOTE_INFO_REGEX = /^[^\s]+\s+[^\s]+\s+\[(.+?)\]/

    attr_reader :raw_name
    attr_reader :upstream_info

    def proper_name
      @proper_name ||= @raw_name.lstrip.sub(CURRENT_BRANCH_REGEX, '')
    end

    def current?
      @current ||= (@raw_name =~ CURRENT_BRANCH_REGEX)
    end

    def merged?
      @merged
    end

    def displayable_name(pad:)
      if pad && !current?
        "  #{@raw_name}"
      else
        @raw_name
      end
    end

    def last_commit_date
      initialize_last_commit_data
      @last_commit_date
    end

    def last_author
      initialize_last_commit_data
      @last_author
    end

    def last_subject
      initialize_last_commit_data
      @last_subject
    end

    # Returns the local branches
    def self.local
      merged_branch_raw_names = Util.command_to_a("git branch --merged").to_set

      branch_info.map do |raw_name, info|
        new(raw_name, merged: merged_branch_raw_names.include?(raw_name), upstream_info: info)
      end
    end

    private

    # Returns a Hash containing, as keys, the raw names of all local branches and, as values,
    # a brief description of each branch's status relative to its upstream branch (up to
    # date, or ahead/behind).
    def self.branch_info
      Util.command_to_a("git branch -vv").map do |line|
        line_is_current_branch = (line =~ LEADING_STAR_REGEX)
        tidied_line = (line_is_current_branch ? line.gsub(LEADING_STAR_REGEX, "") : line)
        proper_branch_name = tidied_line.split(BRANCH_NAME_REGEX)[0]
        raw_branch_name = (line_is_current_branch ? "* #{proper_branch_name}" : proper_branch_name)
        remote_info = tidied_line[REMOTE_INFO_REGEX, 1]
        upstream_info =
          if remote_info.nil?
            "No upstream"
          else
            comparison_raw = remote_info.split(":")
            comparison_raw.length < 2 ? "Up to date" : comparison_raw[1].strip.capitalize
          end
        [raw_branch_name, upstream_info]
      end.to_h
    end

    def self.delete_multi(*branches)
      Util.command_output("git branch -D #{branches.map(&:proper_name).join(" ")} --")
    end

    # raw_name should start in "* " if the current branch, but should otherwise have not whitespace.
    def initialize(raw_name, merged:, upstream_info:)
      @raw_name = raw_name
      @merged = merged
      @upstream_info = upstream_info
    end

    # Returns an array with [date, author, subject], each as a string.
    def initialize_last_commit_data
      return if @last_commit_data

      # For Windows compatibility we need double quotes around the format string, as well as spaces
      # between the placeholders.
      command = %Q(git log -n1 --date=short --format=format:"%cd %n %an %n %s" #{proper_name} --)
      @last_commit_data = Util.command_to_a(command)

      @last_commit_date, @last_author, @last_subject = @last_commit_data
    end

  end

end
