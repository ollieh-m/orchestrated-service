require 'spec_helper'
require_relative '../example_orchestrated_services/all_steps_succeed'

RSpec.describe 'Configuration' do

  let(:called){ AllStepsSucceed.call({param_1: 1}) }

  context 'Steps wrapper can be configured to ActiveRecord transaction globally' do
    before do
      OrchestratedService.configure do |config|
        config.wrapper = OrchestratedService::StepsWrappers::ActiveRecord
      end
    end

    it 'Makes wrapper in an orchestrated service return StepsWrappers::ActiveRecord' do
      expect_any_instance_of(AllStepsSucceed).to receive(:wrapper).and_return(OrchestratedService::StepsWrappers::ActiveRecord)
      allow(ActiveRecord::Base).to receive(:transaction)
      called
    end

    it 'Means a transaction is executed' do
      expect(ActiveRecord::Base).to receive(:transaction)
      called
    end

    after do
      OrchestratedService.reset
    end
  end

  context 'Steps wrapper can be configured to default globally' do
    before do
      OrchestratedService.configure do |config|
        config.wrapper = OrchestratedService::StepsWrappers::Default
      end
    end

    it 'Makes wrapper in an orchestrated service return StepsWrappers::ActiveRecord' do
      expect_any_instance_of(AllStepsSucceed).to receive(:wrapper).and_return(OrchestratedService::StepsWrappers::Default)
      called
    end

    it 'Means the default steps wrapper is performed' do
      expect(OrchestratedService::StepsWrappers::Default).to receive(:perform)
      called
    end

    after do
      OrchestratedService.reset
    end
  end
end
