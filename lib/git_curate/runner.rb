require "highline/import"
require "set"
require "tabulo"
require "tty-screen"

module GitCurate

  # Regexes for unpacking the output of `git branch -vv`
  BRANCH_NAME_REGEX = /\s+/
  REMOTE_INFO_REGEX = /^[^\s]+\s+[^\s]+\s+\[(.+?)\]/

  Branch = Struct.new("Branch", :raw, :proper, :displayable)

  class Runner

    def initialize(opts)
      @opts = opts
    end

    def run
      if ARGV.length != 0
        puts "This script does not accept any arguments."
        exit
      end

      branches = command_to_a("git branch").reject { |raw_branch| excluded_branch?(raw_branch) }.map do |raw_branch|
        Struct::Branch.new(raw_branch, proper_branch(raw_branch), displayable_branch(raw_branch))
      end

      merged_branches = command_to_a("git branch --merged").to_set
      upstream_branches = get_upstream_branches

      table = Tabulo::Table.new(branches, vertical_rule_character: " ", intersection_character: " ",
        horizontal_rule_character: "-", column_padding: 0) do |t|

        t.add_column(:branch, header: "Branch", align_header: :left) { |branch| branch.displayable }

        t.add_column("Last commit", align_header: :left) do |branch|
          `git log -n1 --date=short --format='format:%cd' #{branch.proper}`
        end

        t.add_column("Last author", align_header: :left) do |branch|
          `git log -n1 --format='format:%an' #{branch.proper}`
        end

        t.add_column("Last subject", align_header: :left) do |branch|
          `git log -n1 --format='format:%s' #{branch.proper}`
        end

        t.add_column("Merged\ninto HEAD?", align_header: :left) do |branch|
          merged_branches.include?(branch.proper) ? "Merged" : "Not merged"
        end

        t.add_column("Status vs\nupstream", align_header: :left) do |branch|
          upstream_branches.fetch(branch.proper, "No upstream")
        end
      end

      prompt = " Delete? [y/n/done/abort/help] "
      longest_response = "abort"
      prompt_and_response_width =
        if interactive?
          prompt.length + longest_response.length + 1
        else
          0
        end
      table.shrinkwrap!(max_table_width: TTY::Screen.width - prompt_and_response_width)

      branches_to_delete = []

      table.each_with_index do |row, index|
        if interactive?
          case HighLine.ask("#{row}#{prompt}")
          when "y"
            branches_to_delete << proper_branch(row.to_h[:branch])
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
        else
          puts row
        end
      end
      puts table.horizontal_rule

      finalize(branches_to_delete) if interactive?
    end

    private

    def interactive?
      !@opts[:list]
    end

    def proper_branch(raw_branch)
      raw_branch.lstrip.gsub(/^\*\s*/, '')
    end

    def displayable_branch(raw_branch)
      return raw_branch if interactive?

      current_branch?(raw_branch) ? raw_branch : "  " + raw_branch
    end

    def excluded_branch?(raw_branch)
      interactive? && current_branch?(raw_branch)
    end

    def current_branch?(raw_branch)
      raw_branch =~ /^\s*\*/
    end

    # Returns a Hash containing, as keys, all local branches that have upstream branches,
    # and, as values, a brief description of each branch's status relative to its upstream
    # branch (up to date, or ahead/behind)
    def get_upstream_branches
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
