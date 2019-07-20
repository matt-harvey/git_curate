require "spec_helper"
require "open3"

describe GitCurate::Branch do

  describe "#initialize" do
    it "initializes the @raw_name ivar with the passed value" do
      ["hi", "* master", "coolness", " a", "* something-something"].each do |str|
        branch = GitCurate::Branch.new(str)
        expect(branch.instance_variable_get("@raw_name")).to eq(str)
      end
    end
  end

  describe "#proper_name" do
    it "returns the @raw_name, sans any leading whitespace, sans any leading '* '" do
      {
        "some-branch"            =>  "some-branch",
        "  \t some-other-branch" => "some-other-branch",
        "  * another-one"        => "another-one",
        "* and-this-one"         => "and-this-one",
      }.each do |raw_name, expected_proper_name|

        branch = GitCurate::Branch.new(raw_name)
        expect(branch.proper_name).to eq(expected_proper_name)
      end
    end
  end

  describe "#current?" do
    subject { branch.current? }
    let(:branch) { GitCurate::Branch.new(raw_name) }

    context "when the raw_name begins with '* '" do
      let(:raw_name) { "* hello" }
      it { is_expected.to be_truthy }
    end

    context "when the raw_name does not begin with '* '" do
      let(:raw_name) { "hello" }
      it { is_expected.to be_falsey }
    end
  end

  describe "#displayable_name" do
    subject { branch.displayable_name(pad: pad) }
    let(:branch) { GitCurate::Branch.new(raw_name) }

    context "when the branch is the current branch" do
      let(:raw_name) { "* feature/something" }

      context "even when pad: is passed `true`" do
        let(:pad) { true }

        it "returns the raw name unaltered" do
          is_expected.to eq("* feature/something")
        end
      end
    end

    context "when the branch is not the current branch" do
      let(:raw_name) { "feature/something" }

      context "when pad: is passed `true`" do
        let(:pad) { true }

        it "returns the raw name with two characters padding to the left" do
          is_expected.to eq("  feature/something")
        end
      end

      context "when pad: is passed `false`" do
        let(:pad) { false }

        it "returns the raw name unaltered" do
          is_expected.to eq("feature/something")
        end
      end
    end
  end

  describe "#last_author" do
    it "returns the output from calling `git log -n1 --format=format:%an` with the proper name of the branch" do
      branch = GitCurate::Branch.new("* feature/something")
      command = "git log -n1 --format=format:%an feature/something"
      allow(Open3).to receive(:capture2).with(command).and_return(["John Smith <js@example.com>", nil])
      expect(branch.last_author).to eq("John Smith <js@example.com>")
    end
  end

  describe "#last_commit_date" do
    it "returns the output from calling `git log -n1 --date=short --format=format:%cd` with "\
      "the proper name of the branch" do
      branch = GitCurate::Branch.new("* feature/something")
      command = "git log -n1 --date=short --format=format:%cd feature/something"
      allow(Open3).to receive(:capture2).with(command).and_return(["2019-07-08", nil])
      expect(branch.last_commit_date).to eq("2019-07-08")
    end
  end

  describe "#last_subject" do
    it "returns the output from calling `git log -n1 --format=format:%s` with "\
      "the proper name of the branch" do
      branch = GitCurate::Branch.new("fix/everything")
      command = "git log -n1 --format=format:%s fix/everything"
      allow(Open3).to receive(:capture2).with(command).and_return(["Fix all the things", nil])
      expect(branch.last_subject).to eq("Fix all the things")
    end
  end
end
