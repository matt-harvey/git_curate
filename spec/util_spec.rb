require "spec_helper"
require "open3"

describe GitCurate::Util do

  describe ".command_to_a" do
    subject { GitCurate::Util.command_to_a(command) }
    let(:command) { "some-command" }

    before(:each) do
      allow(Open3).to receive(:capture2).with(command).and_return([output, nil])
    end

    context "when passed a system command that has no output" do
      let(:output) { "" }

      it "returns an empty array" do
        is_expected.to eq([])
      end
    end

    context "when passed a system command that returns one line of output" do
      let(:output) { "  \t  hi   " }

      it "returns a one-element array containing that line, trimmed of leading and trailing whitespace" do
        is_expected.to eq(["hi"])
      end
    end

    context "when passed a system command that returns multiple lines of output" do
      let(:output) { "  \t  hi    #{$/}               there\t\t" }

      it "returns a one-element array containing each of those lines, trimmed of leading and trailing whitespace" do
        is_expected.to eq(["hi", "there"])
      end
    end
  end

  describe ".command_output" do
    subject { GitCurate::Util.command_output(command) }
    let(:command) { "some-command" }

    it "returns the output of the passed string run as a system command" do
      allow(Open3).to receive(:capture2).with(command).and_return(["some output  ", nil])

      is_expected.to eq("some output  ")
    end
  end

end
