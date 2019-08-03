require "spec_helper"

describe GitCurate::Runner do

  describe "#initialize" do
    it "returns a Runner initialized with the passed options" do
      options = { list: true }
      runner = GitCurate::Runner.new(list: true)

      expect(runner.instance_variable_get("@opts")[:list]).to eq(true)
    end
  end

  pending "#run"

end
