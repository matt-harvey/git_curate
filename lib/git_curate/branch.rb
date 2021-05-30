require "rugged"

module GitCurate

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
      last_commit.date
    end

    def hash
      last_commit.hash
    end

    def last_author
      last_commit.author
    end

    def last_subject
      last_commit.subject
    end

    # Returns the local branches
    def self.local
      toplevel_dir = Util.command_output("git rev-parse --show-toplevel").strip
      repo = Rugged::Repository.new(toplevel_dir)

      rugged_branches = repo.branches
      repo_head_target = repo.head.target

      Util.command_to_a("git branch").map do |line|
        raw_branch_name = line.strip
        proper_branch_name = raw_branch_name.gsub(CURRENT_BRANCH_REGEX, "")
        rugged_branch = rugged_branches[proper_branch_name]
        upstream = rugged_branch.upstream
        upstream_data =
          if upstream
            target_id = rugged_branch.target_id
            ahead, behind = repo.ahead_behind(target_id, upstream.target_id)
            parts = []
            parts << "ahead #{ahead}" if ahead != 0
            parts << "behind #{behind}" if behind != 0
            if parts.any?
              parts.join(", ").capitalize
            else
              "Up to date"
            end
          else
            "No upstream"
          end

        target = rugged_branch.resolve.target
        merged = (repo.merge_base(repo_head_target, target) == target.oid)

        new(
          raw_branch_name,
          merged: merged,
          upstream_info: upstream_data,
        )
      end
    end

    private

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

    def last_commit
      @last_commit ||= begin
        # For Windows compatibility we need double quotes around the format string, as well as spaces
        # between the placeholders.
        command = %Q(git log -n1 --date=short --format=format:"%cd %n %h %n %an %n %s" #{proper_name} --)
        Commit.new(*Util.command_to_a(command))
      end
    end

  end

end
