require "spec_helper"
require "open3"

describe GitCurate::Util do

  describe ".command_to_a" do
    subject { GitCurate::Util.command_to_a(command) }
    let(:command) { "some-command" }
    let(:status) { double("status", exitstatus: 0) }

    before(:each) do
      allow(Open3).to receive(:capture3).with(command).and_return([output, err_output, status])
    end

    context "when passed a system command that has no output" do
      let(:output) { "" }
      let(:err_output) { "" }

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

    context "when the passed command does not return a successful exit code" do
      let(:output) { "anything" }
      let(:err_output) { "woops" }
      let(:status) { double("status", exitstatus: 1) }

      it "raises an error with the error output as its message" do
        expect { subject }.to raise_error(GitCurate::SystemCommandError, "woops")
      end
    end
  end

  describe ".command_output" do
    subject { GitCurate::Util.command_output(command) }
    let(:command) { "some-command" }
    let(:status) { double("status", exitstatus: 0) }
    let(:output) { "some output   " }
    let(:err_output) { "" }

    before(:each) do
      allow(Open3).to receive(:capture3).with(command).and_return([output, err_output, status])
    end

    it "returns the output of the passed string run as a system command" do
      is_expected.to eq("some output   ")
    end

    context "when the passed command does not return a successful exit code" do
      let(:output) { "anything" }
      let(:err_output) { "woops" }
      let(:status) { double("status", exitstatus: 1) }

      it "raises an error with the error output as its message" do
        expect { subject }.to raise_error(GitCurate::SystemCommandError, "woops")
      end
    end
  end

end
