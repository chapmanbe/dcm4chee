require "spec_helper"

describe Source do
  let(:valid_attributes) do
    {
      :source   => "http://www.example.com/foo.zip",
      :checksum => "deadbeef"
    }
  end

  let(:source) { Source.new valid_attributes }

  describe "#url" do
    it "returns the URL" do
      expect(source.url).to eq("http://www.example.com/foo.zip")
    end

    it "raises an error when no URL exists" do
      source = Source.new valid_attributes.merge(:source => nil)
      expect { source.url }.to raise_error /url is missing/i
    end
  end

  describe "#checksum" do
    it "returns the checksum" do
      expect(source.checksum).to eq("deadbeef")
    end
  end

  describe "#filename" do
    it "returns the filename by URL" do
      expect(source.filename).to eq("foo.zip")
    end
  end

  describe "#basename" do
    context "when not overwritten by the source attribute" do
      it "determines the basename from filename" do
        expect(source.basename).to eq("foo")
      end
    end

    context "when overwritten by the source attribute" do
      it "returns the source attribute" do
        source = Source.new valid_attributes.merge(:basename => "bar")
        expect(source.basename).to eq("bar")
      end
    end
  end

  describe "#zip?" do
    %w[zip Zip ZIP].each do |suffix|
      it "is true when filename ends with #{suffix}" do
        source = Source.new valid_attributes.merge(
          :source => "http://www.example.com/foo.#{suffix}"
        )
        expect(source.zip?).to be true
      end
    end

    %w[tar.gz gz].each do |suffix|
      it "is false when filename ends with #{suffix}" do
        source = Source.new valid_attributes.merge(
          :source => "http://www.example.com/foo.#{suffix}"
        )
        expect(source.zip?).to be false
      end
    end
  end
end
