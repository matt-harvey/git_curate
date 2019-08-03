module GitCurate

  class Branch

    # Regex for determining whether a "raw" branch name is the name of the current branch
    CURRENT_BRANCH_REGEX = /^\*\s+/

    # Regexes for unpacking the output of `git branch -vv`
    BRANCH_NAME_REGEX = /\s+/
    LEADING_STAR_REGEX = /^\* /
    REMOTE_INFO_REGEX = /^[^\s]+\s+[^\s]+\s+\[(.+?)\]/

    attr_reader :raw_name

    # raw_name should start in "* " if the current branch, but should otherwise have not whitespace.
    def initialize(raw_name)
      @raw_name = raw_name
    end

    def proper_name
      @proper_name ||= @raw_name.lstrip.sub(CURRENT_BRANCH_REGEX, '')
    end

    def current?
      @current ||= (@raw_name =~ CURRENT_BRANCH_REGEX)
    end

    def displayable_name(pad:)
      if pad && !current?
        "  #{@raw_name}"
      else
        @raw_name
      end
    end

    def last_author
      Util.command_output("git log -n1 --format=format:%an #{proper_name} --")
    end

    def last_commit_date
      Util.command_output("git log -n1 --date=short --format=format:%cd #{proper_name} --")
    end

    def last_subject
      Util.command_output("git log -n1 --format=format:%s #{proper_name} --")
    end

    # Returns the local branches
    def self.local
      command_to_branches("git branch")
    end

    # Returns local branches that are merged into current HEAD
    def self.local_merged
      command_to_branches("git branch --merged")
    end

    # Returns a Hash containing, as keys, the proper names of all local branches that have upstream branches,
    # and, as values, a brief description of each branch's status relative to its upstream
    # branch (up to date, or ahead/behind)
    def self.upstream_info
      Util.command_to_a("git branch -vv").map do |line|
        line.gsub!(LEADING_STAR_REGEX, "")
        branch_name = line.split(BRANCH_NAME_REGEX)[0]
        remote_info = line[REMOTE_INFO_REGEX, 1]
        if remote_info.nil?
          nil
        else
          comparison_raw = remote_info.split(":")
          comparison = if comparison_raw.length < 2
                         "Up to date"
                       else
                         comparison_raw[1].strip.capitalize
                       end
          [branch_name, comparison]
        end
      end.compact.to_h
    end

    def self.delete_multi(*branches)
      Util.command_output("git branch -D #{branches.map(&:proper_name).join(" ")} --")
    end

    private

    def self.command_to_branches(command)
      Util.command_to_a(command).map { |raw_branch_name| self.new(raw_branch_name) }
    end

  end

end
