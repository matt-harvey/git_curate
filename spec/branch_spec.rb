require "spec_helper"

describe GitCurate::Branch do

  describe "#initialize" do
    it "initializes the @raw_name ivar with the passed value" do
      ["hi", "* master", "coolness", " a", "* something-something"].each do |str|
        branch = GitCurate::Branch.new(str, merged: false, upstream_info: "whatever")
        expect(branch.instance_variable_get("@raw_name")).to eq(str)
      end
    end
  end

  describe "#proper_name" do
    it "returns the @raw_name, sans any leading whitespace, sans any leading '* '" do
      {
        "some-branch"            => "some-branch",
        "  \t some-other-branch" => "some-other-branch",
        "  * another-one"        => "another-one",
        "* and-this-one"         => "and-this-one",
      }.each do |raw_name, expected_proper_name|

        branch = GitCurate::Branch.new(raw_name, merged: true, upstream_info: "whatever")
        expect(branch.proper_name).to eq(expected_proper_name)
      end
    end
  end

  describe "#current?" do
    subject { branch.current? }
    let(:branch) { GitCurate::Branch.new(raw_name, merged: false, upstream_info: "whatever") }

    context "when the raw_name begins with '* '" do
      let(:raw_name) { "* hello" }
      it { is_expected.to be_truthy }
    end

    context "when the raw_name does not begin with '* '" do
      let(:raw_name) { "hello" }
      it { is_expected.to be_falsey }
    end
  end

  describe "#merged?" do
    it "returns truthy if an only if the branch is merged" do
      expect(GitCurate::Branch.new("hi", merged: true, upstream_info: "whatever").merged?).to be_truthy
      expect(GitCurate::Branch.new("bye", merged: false, upstream_info: "whatever").merged?).to be_falsey
    end
  end

  describe "#displayable_name" do
    subject { branch.displayable_name(pad: pad) }
    let(:branch) { GitCurate::Branch.new(raw_name, merged: true, upstream_info: "whatever") }

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
      branch = GitCurate::Branch.new("* feature/something", merged: false, upstream_info: "whatever")
      command = %Q(git log -n1 --date=short --format=format:"%cd %n %an %n %s" feature/something --)
      allow(GitCurate::Util).to \
        receive(:command_output).
        with(command).
        and_return("2019-07-08#{$/}John Smith <js@example.com>#{$/}Fix all the things")

      expect(branch.last_author).to eq("John Smith <js@example.com>")
    end
  end

  describe "#last_commit_date" do
    it "returns the output from calling `git log -n1 --date=short --format=format:%cd` with "\
      "the proper name of the branch" do
      branch = GitCurate::Branch.new("* feature/something", merged: true, upstream_info: "whatever")
      command = %Q(git log -n1 --date=short --format=format:"%cd %n %an %n %s" feature/something --)
      allow(GitCurate::Util).to \
        receive(:command_output).
        with(command).
        and_return("2019-07-08#{$/}John Smith <js@example.com>#{$/}Fix all the things")

      expect(branch.last_commit_date).to eq("2019-07-08")
    end
  end

  describe "#last_subject" do
    it "returns the output from calling `git log -n1 --format=format:%s` with "\
      "the proper name of the branch" do
      branch = GitCurate::Branch.new("* feature/something", merged: true, upstream_info: "whatever")
      command = %Q(git log -n1 --date=short --format=format:"%cd %n %an %n %s" feature/something --)
      allow(GitCurate::Util).to \
        receive(:command_output).
        with(command).
        and_return("2019-07-08#{$/}John Smith <js@example.com>#{$/}Fix all the things")

      expect(branch.last_subject).to eq("Fix all the things")
    end
  end

  describe ".local" do
    it "returns an array of all the local branches" do
      allow(GitCurate::Util).to receive(:command_to_a).with("git branch --merged").and_return([
        "release",
        "something",
      ])
      allow(GitCurate::Util).to receive(:command_to_a).with("git branch -vv").and_return([
        "* master      5ec7d75 [origin/master] Note untested on Windows",
        "one-command 8827957 WIP... One entry moves",
        "release     5ec7d75 Note untested on Windows",
        "something   6ef7375 [origin/something: behind 15] Words etc",
        "yeah-thing  7efe3b5 [origin/yeah-thing: ahead 2] Words etc",
        "save        a49ea12 [origin/save: ahead 1, behind 2] Save board to disk after each move",
      ])
      result = GitCurate::Branch.local
      expect(result.map(&:raw_name)).to \
        eq(["* master", "one-command", "release", "something", "yeah-thing", "save"])
      expect(result.map(&:merged?)).to \
        eq([false, false, true, true, false, false])
      expect(result.map(&:upstream_info)).to \
        eq(["Up to date", "No upstream", "No upstream", "Behind 15", "Ahead 2", "Ahead 1, behind 2"])
    end
  end

  describe ".delete_multi" do
    it "deletes each of the passed branches by passing their proper names to the `git branch -D` system command" do
      branch_0 = GitCurate::Branch.new("some-branch", merged: false, upstream_info: "whatever")
      branch_1 = GitCurate::Branch.new("* some-other-branch", merged: true, upstream_info: "whatever")
      allow(GitCurate::Util).to receive(:command_output)
      expect(GitCurate::Util).to receive(:command_output).with("git branch -D some-branch some-other-branch --")
      GitCurate::Branch.delete_multi(branch_0, branch_1)
    end
  end

end
