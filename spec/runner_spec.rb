require "spec_helper"

describe GitCurate::Runner do

  describe "#initialize" do
    it "returns a Runner initialized with the passed options" do
      options = { list: true }
      runner = GitCurate::Runner.new(list: true)

      expect(runner.instance_variable_get("@opts")[:list]).to eq(true)
    end
  end

  describe "#run" do
    subject { runner.run(args) }
    let(:runner) { GitCurate::Runner.new(list: list) }
    let(:list) { true }

    before(:each) do
      @branch_0 = GitCurate::Branch.new("a-master", merged: false, upstream_info: "Up to date")
      allow(@branch_0).to receive(:last_commit_date).and_return("2019-03-01")
      allow(@branch_0).to receive(:last_author).and_return("Jane Smithers")
      allow(@branch_0).to receive(:last_subject).and_return("Do some things to the code")

      @branch_1 = GitCurate::Branch.new("b/other-branch", merged: false, upstream_info: "Behind 15")
      allow(@branch_1).to receive(:last_commit_date).and_return("2019-05-02")
      allow(@branch_1).to receive(:last_author).and_return("John Smith")
      allow(@branch_1).to receive(:last_subject).and_return("Implement that cool feature")

      @branch_2 = GitCurate::Branch.new("* c-another-one", merged: true, upstream_info: "No upstream")
      allow(@branch_2).to receive(:last_commit_date).and_return("2017-11-24")
      allow(@branch_2).to receive(:last_author).and_return("John Smith")
      allow(@branch_2).to receive(:last_subject).and_return("Fix that bug")

      @branch_3 = GitCurate::Branch.new("d-fourth", merged: false, upstream_info: "No upstream")
      allow(@branch_3).to receive(:last_commit_date).and_return("2017-11-24")
      allow(@branch_3).to receive(:last_author).and_return("John Smith")
      allow(@branch_3).to receive(:last_subject).and_return("Fix that bug")

      @branch_4 = GitCurate::Branch.new("e-fifth", merged: true, upstream_info: "Ahead 1, behind 2")
      allow(@branch_4).to receive(:last_commit_date).and_return("2010-08-08")
      allow(@branch_4).to receive(:last_author).and_return("Alicia Keys")
      allow(@branch_4).to receive(:last_subject).and_return("More things")

      allow(GitCurate::Branch).to receive(:local).and_return([@branch_0, @branch_1, @branch_2, @branch_3, @branch_4])
      allow(TTY::Screen).to receive(:width).and_return(200)
      allow($stdout).to receive(:puts) { |output| @captured_output = output }
    end

    after(:each) do
      @captured_output = nil
    end

    context "when passed arguments" do
      let(:args) { ['hi'] }
      before(:each) { allow($stderr).to receive(:puts).and_return(nil) }

      it "returns a code of 1, indicating failure" do
        is_expected.to eq(1)
      end

      it "prints an error message to STDERR" do
        expect(STDERR).to receive(:puts).with("This script does not accept any arguments.")
        subject
      end
    end

    context "when not passed any arguments" do
      let(:args) { [] }
      before(:each) { allow(GitCurate::Branch).to receive(:delete_multi) }

      context "when Runner was initialized with `list: true`" do
        let(:list) { true }

        it "outputs a list of branch information" do
          # Doing it like this to stop text editor automatically deleting trailing whitespace
          expected_output = [
" ---------------- ----------- ------------- --------------------------- ---------- ----------------- ",
" Branch           Last commit Last author   Last subject                Merged     Status vs         ",
"                                                                        into HEAD? upstream          ",
" ---------------- ----------- ------------- --------------------------- ---------- ----------------- ",
"   a-master       2019-03-01  Jane Smithers Do some things to the code  Not merged Up to date        ",
"   b/other-branch 2019-05-02  John Smith    Implement that cool feature Not merged Behind 15         ",
" * c-another-one  2017-11-24  John Smith    Fix that bug                Merged     No upstream       ",
"   d-fourth       2017-11-24  John Smith    Fix that bug                Not merged No upstream       ",
"   e-fifth        2010-08-08  Alicia Keys   More things                 Merged     Ahead 1, behind 2 ",
" ---------------- ----------- ------------- --------------------------- ---------- ----------------- ",
          ].join($/)

          subject

          expect(@captured_output).to eq(expected_output)
        end

        it "returns a code of 0, indicating success" do
          is_expected.to eq(0)
        end
      end

      context "when Runner was initialized with `list: false`" do
        let(:list) { false }
        let(:user_responses) { ["y", "", "N", "Y"] }
        before(:each) { allow(HighLine).to receive(:ask).and_return(*user_responses) }

        it "prompts the user once for each branch other than the current one, continuing if the user enters a y/Y/n/N/<blank>" do
          expect(HighLine).to receive(:ask).exactly(4).times
          subject
        end

        it "deletes each branch for which the user enters 'y' or 'Y'" do
          expect(GitCurate::Branch).to receive(:delete_multi).with(@branch_0, @branch_4)
          subject
        end

        it "returns a status code of 0" do
          is_expected.to eq(0)
        end

        context "when the user enters 'abort'" do
          let(:user_responses) { ["y", "Y", "abort"] }

          it "exits early" do
            expect(HighLine).to receive(:ask).exactly(3).times
            subject
          end

          it "does not delete any branches" do
            expect(GitCurate::Branch).not_to receive(:delete_multi)
            subject
          end

          it "returns a status code of 0" do
            is_expected.to eq(0)
          end
        end

        context "when the user enters 'done'" do
          let(:user_responses) { ["y", "", "done"] }

          it "exits early" do
            expect(HighLine).to receive(:ask).exactly(3).times
            subject
          end

          it "deletes the branches that the user has selected for deletion using 'y'/'Y'" do
            expect(GitCurate::Branch).to receive(:delete_multi).with(@branch_0)
            subject
          end

          it "returns a status code of 0" do
            is_expected.to eq(0)
          end
        end

        context "when the user enters 'help'" do
          let(:user_responses) { ["n", "help", "n", "n"] }

          it "outputs help text" do
            expected_help_text = <<-EOL
  Simply hit <Enter> to keep this branch and skip to the next one;
  or enter one of the following commands:
    y      -- mark branch for deletion
    n      -- keep branch (equivalent to just <Enter>)
    done   -- delete selected branches and exit session
    abort  -- abort without deleting any branches
    help   -- print this help message
  EOL
            expect($stdout).to receive(:puts).with(expected_help_text)
            subject
          end
        end
      end
    end

  end

end
