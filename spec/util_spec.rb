require "spec_helper"

describe GitCurate::Util do

  describe ".command_to_a" do
    subject { GitCurate::Util.command_to_a(command) }
    let(:command) { "some-command" }

    before(:each) do
      allow(GitCurate::Util).to receive(:`).with(command).and_return(output)
    end

    context "when passed a system command that has no output" do
      let(:output) { "" }

      it "returns an empty array" do
        is_expected.to eq([])
      end
    end

    context "when passed a system command that returns one line of output" do
      let(:output) { "  \t  hi   " }
      let(:err_output) { "" }

      it "returns a one-element array containing that line, trimmed of leading and trailing whitespace" do
        is_expected.to eq(["hi"])
      end
    end

    context "when passed a system command that returns multiple lines of output" do
      let(:output) { "  \t  hi    #{$/}               there\t\t" }
      let(:err_output) { "" }

      it "returns a one-element array containing each of those lines, trimmed of leading and trailing whitespace" do
        is_expected.to eq(["hi", "there"])
      end
    end
  end

  describe ".command_output" do
    subject { GitCurate::Util.command_output(command) }
    let(:command) { "some-command" }
    let(:output) { "hi" }

    before(:each) do
      allow(GitCurate::Util).to receive(:`).with(command).and_return(output)
    end

    it "returns the output from running the passed string as a system command" do
      is_expected.to eq("hi")
    end
  end

end
