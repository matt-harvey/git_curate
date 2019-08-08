require "spec_helper"

describe GitCurate::SystemCommandError do

  describe "#initialize" do
    subject do
      GitCurate::SystemCommandError.new("woops", 1)
    end

    it "creates a new SystemCommandError instance" do
      is_expected.to be_a(GitCurate::SystemCommandError)
    end

    it "populates the new SystemCommandError with an exit status" do
      expect(subject.exit_status).to eq(1)
    end

    it "populates the error message of the exception with the passed message" do
      expect(subject.message).to eq("woops")
    end
  end

end
