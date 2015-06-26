require "spec_helper"

describe Souse::GherkinCollection do
  let(:test_path) { double("path") }
  let(:parser) { Souse::GherkinCollection.new test_path }
  
  describe "#parse_path" do
    context "with a file path" do
      before { expect(test_path).to receive(:end_with?).with(".feature").and_return(true) }
      
      it "returns an array" do
        expect(parser.parse_path).to be_an(Array)
      end

      it "returns only the file path" do
        collection = parser.parse_path
        expect(collection.size).to eq 1
        expect(collection.first).to eq test_path
      end
    end

    context "with a directory path" do
      before { expect(test_path).to receive(:end_with?).with(".feature").and_return(false) }

      it "returns an array" do
        expect(parser.parse_path).to be_an(Array)
      end

      it "globs for a recursive list of feature files" do
        expect(Dir).to receive(:glob).with("#{test_path}/**/*.feature")
        parser.parse_path
      end
    end
  end

  describe "#to_json" do
    let(:feature) { double("array") }
    
    before do
      expect(parser).to receive(:parse_path).and_return(feature)
      expect(feature).to receive(:each).once
      expect(MultiJson).to receive(:load).with(parser.io.string)
    end
    
    it "iterates over the list of feature files" do
      parser.to_json
    end

    it "closes the formattter" do
      expect(parser.format).to receive(:done)
      parser.to_json
    end
  end
end
