require "highline/import"
require "set"
require "tabulo"
require "tty-screen"

module GitCurate

  class Runner

    def initialize(opts)
      @opts = opts
    end

    def run
      if ARGV.length != 0
        puts "This script does not accept any arguments."
        exit
      end

      branches = Branch.local
      branches.reject!(&:current?) if interactive?
      merged_branch_names = Branch.local_merged.map(&:proper_name).to_set
      upstream_branches = Branch.upstream_info

      table = Tabulo::Table.new(branches, vertical_rule_character: " ", intersection_character: " ",
        horizontal_rule_character: "-", column_padding: 0, align_header: :left) do |t|

        t.add_column(:branch, header: "Branch") { |b| b.displayable_name(pad: !interactive?) }
        t.add_column("Last commit", &:last_commit_date)
        t.add_column("Last author", &:last_author)
        t.add_column("Last subject", &:last_subject)
        t.add_column("Merged#{$/}into HEAD?") { |b| merged_branch_names.include?(b.proper_name) ? "Merged" : "Not merged" }
        t.add_column("Status vs#{$/}upstream") { |b| upstream_branches.fetch(b.proper_name, "No upstream") }
      end

      prompt = " Delete? [y/N/done/abort/help] "
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
        case HighLine.ask("#{row}#{prompt}").downcase
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

  end

end
