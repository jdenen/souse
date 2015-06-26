require "spec_helper"

describe Souse::Reformatter do
  let(:reform) { Souse::Reformatter }

  describe "#reformat_scenario" do
    let(:scenario) do
      {
        "name"  => "Foo",
        "tags"  => [{"name" => "@foo", "keyword" => "tag"}],
        "steps" => [{"keyword" => "Given ", "name" => "foobar"}]
      }
    end
    
    it "returns a hash" do
      expect(reform.reformat_scenario "Foobar", scenario).to be_a Hash
    end

    it "returns one key in the hash" do
      hash_keys = reform.reformat_scenario("Foobar", scenario).keys
      expect(hash_keys.size).to eq 1
      expect(hash_keys.first).to eq "Foo"
    end

    it "reformats the scenario hash" do
      reformatted = reform.reformat_scenario("Foobar", scenario)["Foo"]
      expect(reformatted["feature"]).to eq "Foobar"
      expect(reformatted["tags"]).to eq ["@foo"]
      expect(reformatted["steps"]).to eq ["Given foobar"]
    end
  end

  describe "#reformat_example_table" do
    let(:examples) do
      [{ "rows" => [{"cells" => ["foo", "bar"]}, {"cells" => ["one", "two"]}] }]
    end

    let(:reformed_table) { reform.reformat_table examples }
    
    it "returns a hash" do
      expect(reformed_table).to be_a Hash
    end

    it "reformats the table headers into hash keys" do
      expect(reformed_table.keys).to eq ["foo", "bar"]
    end

    it "reformats table rows into array values under each header key" do
      expect(reformed_table["foo"]).to eq ["one"]
      expect(reformed_table["bar"]).to eq ["two"]
    end
  end

  describe "#reformat_outline" do
    let(:examples) { { "bar" => ["a", "b"], "baz" => ["c", "d"] } }
    
    let(:outline) do
      {
        "name"     => "Bar",
        "tags"     => [{"keyword" => "tag", "name" => "@bar"}],
        "steps"    => [{"keyword" => "Given ", "name" => "foo <bar>"},
                       {"keyword" => "Then ", "name"  => "foo <baz>"}]
      }
    end

    let(:reformed_outline) { reform.reformat_outline "Foobar", outline, examples }

    it "returns a hash" do
      expect(reformed_outline).to be_a Hash
    end

    it "returns as many scenarios as there are data rows" do
      expect(reformed_outline.keys.size).to eq 2
    end

    it "appends the data index to the scenario name" do
      keys = reformed_outline.keys
      keys.each_with_index { |k, i| expect(k).to match /#{i + 1}/ }
    end

    it "replaces data placeholders with data in the steps" do
      first_scenario_steps  = reformed_outline.values[0]["steps"]
      second_scenario_steps = reformed_outline.values[1]["steps"]
      expect(first_scenario_steps.first).to eq "Given foo a"
      expect(first_scenario_steps.last).to eq "Then foo c"
      expect(second_scenario_steps.first).to eq "Given foo b"
      expect(second_scenario_steps.last).to eq "Then foo d"
    end
  end

  describe "#reformat_gherkin" do
    let(:remove) do
      {
        "name" => "Foo",
        "elements" => [{"type" => "scenario"}, {"type" => "scenario_outline"}]
      }
    end

    it "passes scenarios to #reformat_scenario" do
      feature = [{"name" => "Foo", "elements" => [{"type" => "scenario"}]}]
      expect(reform).to receive(:reformat_scenario).with("Foo", {"type" => "scenario"})
      reform.reformat_gherkin feature
    end

    it "passes scenario outlines to #reformat_outline" do
      feature = [{"name" => "Bar", "elements" => [{"type" => "scenario_outline", "examples" => [:test]}]}]
      example = double("examples table")
      expect(reform).to receive(:reformat_table).with([:test]).and_return example
      expect(reform).to receive(:reformat_outline).with("Bar", {"type" => "scenario_outline", "examples" => [:test]}, example)
      reform.reformat_gherkin feature
    end
  end
  
end
