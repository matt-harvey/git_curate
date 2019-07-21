require "spec_helper"
require "optparse"

describe GitCurate::CLIParser do

  describe "#initialize" do
    subject { GitCurate::CLIParser.new }

    it "initializes @parsed_options with an empty Hash" do
      expect(subject.parsed_options).to eq({})
    end
  end

  describe "#parse" do
    subject { cli_parser.parse(options) }
    let(:cli_parser) { GitCurate::CLIParser.new }

    context "when passed invalid options" do
      let(:options) { ["--something"] }

      it "raises OptionParser::InvalidOption" do
        expect { subject }.to raise_error(OptionParser::InvalidOption)
      end
    end

    context "when passed valid options" do
      let(:options) { ["-v"] }

      it "does not raise an error" do
        expect { subject }.not_to raise_error
      end

      context "when passed -v or --version" do
        let(:options) { ["-v"] }

        it "returns falsey, indicating that the program should not continue" do
          is_expected.to be_falsey
        end

        it "prints application version and copyright information" do
          expect { subject }.to output(/git curate v\d+\.\d+\.\d+ \(c\) \d{4} Matthew Harvey/).to_stdout
        end
      end

      context "when passed -h" do
        let(:options) { ["-h"] }

        it "returns falsey, indicating that the program should not continue" do
          is_expected.to be_falsey
        end

        it "prints help information" do
          expect { subject }.to output(/Usage: .*options.*/).to_stdout
        end
      end

      context "when passed -l or --list" do
        let(:options) { ["-l"] }

        it "returns truthy, indicating that the program should continue" do
          is_expected.to be_truthy
        end

        it "sets the --list entry to true in parsed_options" do
          subject
          expect(cli_parser.parsed_options[:list]).to eq(true)
        end
      end
    end
  end
end
