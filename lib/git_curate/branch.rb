module GitCurate

  UpstreamInfo = Struct.new(:upstream, :status)

  class Branch

    # Regex for determining whether a "raw" branch name is the name of the current branch
    # on this or another worktree.
    CURRENT_BRANCH_REGEX = /^[+*]\s+/

    # Returns the branch name, with "* " prefixed if it's the current branch on the current
    # worktree, or "+ " if it's the current branch on another worktree.
    attr_reader :raw_name

    # Returns a human-friendly string describing the status of the branch relative to the upstream branch
    # it's tracking, if any.
    attr_reader :upstream_info

    # Returns simply the name of the branch, without any other "decoration".
    def proper_name
      @proper_name ||= @raw_name.lstrip.sub(CURRENT_BRANCH_REGEX, '')
    end

    def current?
      @current ||= (@raw_name =~ CURRENT_BRANCH_REGEX)
    end

    # Return truthy if and only if this branch has been merged into the current HEAD.
    def merged?
      @merged
    end

    # Returns the branch's name, with a prefix of "* ", if it's the currently checked out branch, or, if it's not
    # the currently checked out branch, either a prefix of "  " (if `pad:` receives truthy) or no prefix (if `pad:`
    # received falsey). Branch displayable names are designed to be aligned with each other for display in a vertical
    # column. `pad:` should generally be passed `false` if the caller knows that the current branch won't be in the
    # list of displayed branches.
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

    def hash
      initialize_last_commit_data
      @hash
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
      # Double quotes around the format string to ensure Windows compatibility.
      command = 'git for-each-ref --format="%(refname:short) .. %(upstream:short) .. %(upstream:track)" refs/heads'
      branches_with_remotes = Util.command_to_a(command).map do |line|
        parts = line.split("..", -1).map { |s| s.strip! ; s.empty? ? nil : s }
        [parts[0], UpstreamInfo.new(parts[1], parts[2])]
      end.to_h

      info = Util.command_to_a("git branch").map do |line|
        raw_branch_name = line.strip
        proper_branch_name = raw_branch_name.gsub(CURRENT_BRANCH_REGEX, "")
        upstream_info = branches_with_remotes[proper_branch_name]
        upstream_data =
          if upstream_info.upstream
            status = upstream_info.status
            if status
              status.gsub(/^\[/, "").gsub(/\]$/, "").capitalize
            else
              "Up to date"
            end
          else
            "No upstream"
          end
        [raw_branch_name, upstream_data]
      end

      info.to_h
    end

    def self.delete_multi(*branches)
      Util.command_output("git branch -D #{branches.map(&:proper_name).join(" ")} --")
    end

    # raw_name should start in "* " if the current branch on this worktree, "+ " if it's the current
    # branch on another worktree, or otherwise have no whitespace.
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
      command = %Q(git log -n1 --date=short --format=format:"%cd %n %h %n %an %n %s" #{proper_name} --)
      @last_commit_data = Util.command_to_a(command)

      @last_commit_date, @hash, @last_author, @last_subject = @last_commit_data
    end

  end

end
