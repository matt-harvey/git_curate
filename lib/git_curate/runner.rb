module GitCurate

  # Regexes for unpacking the output of `git branch -vv`
  BRANCH_NAME_REGEX = /\s+/
  REMOTE_INFO_REGEX = /^[^\s]+\s+[^\s]+\s+\[(.+?)\]/

  class Runner

    def run
      if ARGV.length != 0
        puts "This script does not accept any arguments."
        exit
      end

      branches = command_to_a("git branch").reject { |b| current_branch?(b) }
      merged_branches = command_to_a("git branch --merged").reject { |b| current_branch?(b) }.to_set
      upstreams = upstream_branches

      table = Tabulo::Table.new(branches, vertical_rule_character: " ", intersection_character: " ",
        horizontal_rule_character: "-", column_padding: 0) do |t|

        t.add_column(:branch, header: "Branch", align_header: :left) { |branch| branch }

        t.add_column("Last commit", align_header: :left) do |branch|
          `git log -n1 --date=short --format='format:%cd' #{branch}`
        end

        t.add_column("Last author", align_header: :left) do |branch|
          `git log -n1 --format='format:%an' #{branch}`
        end

        t.add_column("Last subject", align_header: :left) do |branch|
          `git log -n1 --format='format:%s' #{branch}`
        end

        t.add_column("Merged\ninto HEAD?", align_header: :left) do |branch|
          merged_branches.include?(branch) ? "Merged" : "Not merged"
        end

        t.add_column("Status vs\nupstream", align_header: :left) do |branch|
          upstreams.fetch(branch, "No upstream")
        end
      end

      table.shrinkwrap!(max_table_width: 150)

      branches_to_delete = []

      table.each_with_index do |row, index|
        case HighLine.ask("#{row} Delete? [y/n/done/abort/help] ")
        when "y"
          branches_to_delete << row.to_h[:branch]
        when "n"
          ;  # do nothing
        when "done"
          puts table.horizontal_rule
          finalize(branches_to_delete)
          exit
        when "abort"
          puts table.horizontal_rule
          puts "\nAborting. No branches deleted."
          exit
        else
          puts table.horizontal_rule
          print_help
          puts table.horizontal_rule unless index == 0
          redo
        end
      end
      puts table.horizontal_rule

      finalize(branches_to_delete)
    end

    private

    def current_branch?(branch)
      branch =~ /^\s*\*/
    end

    # Returns a Hash containing, as keys, all local branches that have upstream branches,
    # and, as values, a brief description of each branch's status relative to its upstream
    # branch (up to date, or ahead/behind)
    def upstream_branches
      command_to_a("git branch -vv").map do |line|
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

    def finalize(branches_to_delete)
      if branches_to_delete.size != 0
        puts
        system("git branch -D #{branches_to_delete.join(" ")}")
        puts "\nDone"
      else
        puts "\nNo branches deleted."
      end
    end

    def print_help
      puts <<-EOL
  Please enter one of:
    y      -- mark branch for deletion
    n      -- keep branch
    done   -- delete marked branches and exit session
    abort  -- abort without deleting any branches
    help   -- print this help message
  EOL
    end

    # Runs the passed string command as a system command, gathers any lines of output, stripped of
    # leading and trailing whitespace, and returns them as an array.
    def command_to_a(command)
      `#{command}`.split($/).map(&:strip)
    end

  end

end
