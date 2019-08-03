require "spec_helper"

describe GitCurate::App do

  describe "#main" do
    subject { GitCurate::App.main }
    let(:parser) { double("parser") }
    let(:continue_past_parser) { false }

    before(:each) do
      allow(GitCurate::CLIParser).to receive(:new).and_return(parser)
      allow(parser).to receive(:parse).and_return(continue_past_parser)
    end

    it "parses command line arguments" do
      expect(parser).to receive(:parse)
      subject
    end

    context "when the parser returns false, indicating valid CLI args, but that the program should not continue" do
      let(:continue_past_parser) { false }

      it "returns 0, indicating success" do
        is_expected.to eq(0)
      end

      it "does not continue" do
        expect(GitCurate::Runner).not_to receive(:new)
        subject
      end
    end

    context "when the parser encounters an invalid option" do
      before(:each) do
        allow(parser).to receive(:parse).and_raise(OptionParser::InvalidOption)
      end

      it "does not continue" do
        expect(GitCurate::Runner).not_to receive(:new)
        subject
      end

      it "outputs an error message" do
        expect($stdout).to receive(:puts).with("Unrecognized option").ordered
        expect($stdout).to receive(:puts).with("For help, enter `git curate -h`").ordered
        subject
      end

      it "returns 1, indicating error" do
        is_expected.to eq(1)
      end
    end

    context "when the parser returns true, indicating valid CLI args, and that the program should continue" do
      let(:continue_past_parser) { true }
      before(:each) { allow(parser).to receive(:parsed_options).and_return({ list: true }) }

      it "proceeds to process the git branches with a Runner instance, passing the runner the parsed options" do
        runner = double("runner")
        allow(GitCurate::Runner).to receive(:new).and_return(runner)
        allow(runner).to receive(:run)
        expect(GitCurate::Runner).to receive(:new).with(list: true)
        expect(runner).to receive(:run)
        subject
      end
    end

  end

end
