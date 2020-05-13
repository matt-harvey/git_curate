require "highline/import"
require "set"
require "tabulo"
require "tty-screen"

module GitCurate

  # Contains the main logic of the application.
  class Runner

    # Accepts a Hash of options passed from the parsed command line. Currently there is only one option, :list,
    # which is treated as a boolean, and determines whether the branches will simply be listed non-interactively
    # (list: true), or interactively with opportunities for the user to select branches for deletion (list: false).
    def initialize(opts)
      @opts = opts
    end

    # Runs the application, listing branches either interactively or non-interactively. Returns an exit status,
    # suitable for passing to `exit()`.
    # `args` should be passed an array of non-option/non-flag arguments received from the command
    # line. If this array is of inappropriate length, EXIT_FAILURE will be returned. (The
    # appropriate length may be 0.)
    def run(args)
      if args.length != 0
        $stderr.puts "This script does not accept any arguments."
        return EXIT_FAILURE
      end

      branches = Branch.local
      branches.reject!(&:current?) if interactive?

      table = Tabulo::Table.new(branches, border: :reduced_ascii, column_padding: 0, align_header: :left) do |t|
        t.add_column(:branch, header: "Branch") { |b| b.displayable_name(pad: !interactive?) }
        t.add_column("Last commit:#{$/}Date", &:last_commit_date)
        t.add_column("#{$/}Hash", &:hash)
        t.add_column("#{$/}Author", &:last_author)
        t.add_column("#{$/}Subject", &:last_subject)
        t.add_column("Merged#{$/}into HEAD?") { |b| b.merged? ? "Merged" : "Not merged" }
        t.add_column("Status vs#{$/}upstream", &:upstream_info)
      end

      prompt = " d/[k]/e/a ? "
      prompt_and_response_width = (interactive? ? (prompt.length + 2) : 0)
      max_table_width = TTY::Screen.width - prompt_and_response_width
      table.pack(max_table_width: max_table_width)

      branches_to_delete = []

      if !interactive?
        puts table
        return EXIT_SUCCESS
      end

      if branches.empty?
        puts "There are no local branches that can be deleted."
        return EXIT_SUCCESS
      end

      puts
      print_help
      puts

      table.each_with_index do |row, index|
        case HighLine.ask("#{row} #{prompt}").downcase
        when "d"
          branches_to_delete << row.source
        when "k", ""
          ;  # do nothing
        when "e"
          puts table.horizontal_rule
          finalize(branches_to_delete)
          return EXIT_SUCCESS
        when "a"
          puts table.horizontal_rule
          puts "#{$/}Aborting. No branches deleted."
          return EXIT_SUCCESS
        else
          puts table.horizontal_rule
          print_help
          puts table.horizontal_rule unless index == 0
          redo
        end
      end
      puts table.horizontal_rule

      finalize(branches_to_delete)
      return EXIT_SUCCESS
    end

    private

    def interactive?
      !@opts[:list]
    end

    def finalize(branches_to_delete)
      if branches_to_delete.size != 0
        puts
        puts Branch.delete_multi(*branches_to_delete)
        puts "#{$/}Done"
      else
        puts "#{$/}No branches deleted."
      end
    end

    def print_help
      instructions = [
        ["d :", "delete branch"],
        ["k / <enter> :", "keep branch"],
        ["e :", "end session, deleting all selected branches"],
        ["a :", "abort session, keeping all branches"],
      ]
      instructions_table = Tabulo::Table.new(instructions, border: :blank, header_frequency: nil,
        column_padding: [1, 0]) do |t|

        t.add_column(0, align_body: :right, &:first)
        t.add_column(1, &:last)
      end
      puts instructions_table.pack
    end

  end

end
