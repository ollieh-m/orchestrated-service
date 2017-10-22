require 'spec_helper'

RSpec.describe OrchestratedService::Feedback do
  context "#success" do
    it "default to true" do
      expect(described_class.new.success).to eq true
    end

    it "can be false" do
      expect(described_class.new(success: false).success).to eq false
    end

    it "cannot be anything else" do
      expect {
        described_class.new(success: 'potato')
      }.to raise_error(OrchestratedService::Errors::InvalidFeedbackError)
    end
  end

  context "#result" do
    it "default to nil" do
      expect(described_class.new.result).to eq nil
    end

    it "can be set to anything else" do
      expect(described_class.new(result: 'potato').result).to eq 'potato'
    end
  end

  context "#soft_stop" do
    it "default to nil" do
      expect(described_class.new.soft_stop).to eq nil
    end

    it "can be true" do
      expect(described_class.new(soft_stop: true).soft_stop).to eq true
    end

    it "cannot be anything else" do
      expect {
        described_class.new(soft_stop: 'potato')
      }.to raise_error(OrchestratedService::Errors::InvalidFeedbackError)
    end
  end

end
