require_relative '../example_orchestrated_services/active_record_wrapper'
require_relative '../example_orchestrated_services/all_steps_succeed'

RSpec.describe 'Steps wrapped' do

  context 'ActiveRecord transaction can be specified as the steps wrapper' do
    let(:called){ ActiveRecordWrapper.call({params_1: 1}) }

    context 'The steps are carried out as the bock for a transaction' do
      it 'If the transaction does not yield, the steps are not carried out' do
        allow(ActiveRecord::Base).to receive(:transaction)
        expect_any_instance_of(ActiveRecordWrapper).not_to receive :first_step
        expect_any_instance_of(ActiveRecordWrapper).not_to receive :second_step
        expect_any_instance_of(ActiveRecordWrapper).not_to receive :third_step
        expect(called.result).to eq({success: nil})
      end

      it 'Steps are carried out when the transaction yields' do
        allow(ActiveRecord::Base).to receive(:transaction).and_yield
        expect(called.success).to eq true
        expect(called.result[:success]).to eq({'result of third step' => 'works'})
      end
    end
  end

  context 'The default wrapper carries out the steps without a transaction' do
    let(:called){ AllStepsSucceed.call({params_1: 1}) }

    context 'The steps are carried out as a block for Default.perform' do
      it 'If perform does not yield, the steps are not carried out' do
        allow(OrchestratedService::StepsWrappers::Default).to receive(:perform)
        expect_any_instance_of(ActiveRecordWrapper).not_to receive :first_step
        expect_any_instance_of(ActiveRecordWrapper).not_to receive :second_step
        expect_any_instance_of(ActiveRecordWrapper).not_to receive :third_step
        expect(called.result).to eq({success: nil})
      end

      it 'Steps are carried out when perform yields' do
        allow(OrchestratedService::StepsWrappers::Default).to receive(:perform).and_yield
        expect(called.success).to eq true
        expect(called.result[:success]).to eq({'result of third step' => 'works'})
      end

      it 'No transaction needs to yield' do
        allow(ActiveRecord::Base).to receive(:transaction)
        allow(OrchestratedService::StepsWrappers::Default).to receive(:perform).and_yield
        expect(called.success).to eq true
        expect(called.result[:success]).to eq({'result of third step' => 'works'})
      end

      it 'No transaction is called' do
        expect(ActiveRecord::Base).not_to receive(:transaction)
        called
      end
    end
  end
end
