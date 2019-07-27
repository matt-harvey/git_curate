require "highline/import"
require "set"
require "tabulo"
require "tty-screen"

module GitCurate

  # Regexes for unpacking the output of `git branch -vv`
  BRANCH_NAME_REGEX = /\s+/
  LEADING_STAR_REGEX = /^\* /
  REMOTE_INFO_REGEX = /^[^\s]+\s+[^\s]+\s+\[(.+?)\]/

  class Runner

    def initialize(opts)
      @opts = opts
    end

    def run
      if ARGV.length != 0
        puts "This script does not accept any arguments."
        exit
      end

      branches = command_to_a("git branch").map { |b| Branch.new(b) }
      branches.reject!(&:current?) if interactive?
      merged_branches = command_to_a("git branch --merged").to_set
      upstream_branches = get_upstream_branches

      table = Tabulo::Table.new(branches, vertical_rule_character: " ", intersection_character: " ",
        horizontal_rule_character: "-", column_padding: 0, align_header: :left) do |t|

        t.add_column(:branch, header: "Branch") { |b| b.displayable_name(pad: !interactive?) }
        t.add_column("Last commit", &:last_commit_date)
        t.add_column("Last author", &:last_author)
        t.add_column("Last subject", &:last_subject)
        t.add_column("Merged#{$/}into HEAD?") { |b| merged_branches.include?(b.proper_name) ? "Merged" : "Not merged" }
        t.add_column("Status vs#{$/}upstream") { |b| upstream_branches.fetch(b.proper_name, "No upstream") }
      end

      prompt = " Delete? [y/n/done/abort/help] "
      longest_response = "abort"
      prompt_and_response_width = (interactive? ? (prompt.length + longest_response.length + 1) : 0)
      table.pack(max_table_width: TTY::Screen.width - prompt_and_response_width)

      branches_to_delete = []

      if !interactive?
        puts table
        puts table.horizontal_rule
        return
      end

      table.each_with_index do |row, index|
        case HighLine.ask("#{row}#{prompt}")
        when "y"
          branches_to_delete << row.source.proper_name
        when "n", ""
          ;  # do nothing
        when "done"
          puts table.horizontal_rule
          finalize(branches_to_delete)
          exit
        when "abort"
          puts table.horizontal_rule
          puts "#{$/}Aborting. No branches deleted."
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

    def interactive?
      !@opts[:list]
    end

    # Returns a Hash containing, as keys, all local branches that have upstream branches,
    # and, as values, a brief description of each branch's status relative to its upstream
    # branch (up to date, or ahead/behind)
    def get_upstream_branches
      command_to_a("git branch -vv").map do |line|
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

    def finalize(branches_to_delete)
      if branches_to_delete.size != 0
        puts
        system("git branch -D #{branches_to_delete.join(" ")}")
        puts "#{$/}Done"
      else
        puts "#{$/}No branches deleted."
      end
    end

    def print_help
      puts <<-EOL
  Simply hit <Enter> to keep this branch and skip to the next one;
  or enter one of the following commands:
    y      -- mark branch for deletion
    n      -- keep branch (equivalent to just <Enter>)
    done   -- delete selected branches and exit session
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
