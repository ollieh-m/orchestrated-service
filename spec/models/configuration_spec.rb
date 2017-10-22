require 'spec_helper'

RSpec.describe OrchestratedService::Configuration do
  context "#wrapper" do
    it "default value is OrchestratedService::StepsWrappers::Default" do
      expect(described_class.new.wrapper).to eq OrchestratedService::StepsWrappers::Default
    end
  end

  describe "#wrapper=" do
    it "can set value" do
      config = described_class.new
      config.wrapper = OrchestratedService::StepsWrappers::ActiveRecord
      expect(config.wrapper).to eq(OrchestratedService::StepsWrappers::ActiveRecord)
    end

    it "cannot set to an invalid value" do
      config = described_class.new
      expect {
        config.wrapper = 'Potato'
      }.to raise_error(OrchestratedService::Errors::InvalidWrapperError)
    end
  end
end
