require 'spec_helper'
require_relative '../example_orchestrated_services/all_steps_succeed'
require_relative '../example_orchestrated_services/step_fails'
require_relative '../example_orchestrated_services/uses_previous_results'
require_relative '../example_orchestrated_services/nested_steps_success'
require_relative '../example_orchestrated_services/nested_steps_fail'
require_relative '../example_orchestrated_services/nested_soft_stop'

RSpec.describe 'Service including orchestrate' do

  context 'All steps succeed' do
    let!(:called){ AllStepsSucceed.call({param_1: 1}) }

    it 'Returns success' do
      expect(called.success).to eq true
    end

    it 'Returns the result of the final step in .result[:success]' do
      expect(called.result[:success]).to eq({'result of third step' => 'works'})
    end

    it 'Final step result can be a hash without setting .result[:success] to nil' do
      expect(called.result[:success].class).to eq Hash
    end

    it 'Returns the result of each step in .result[:name_of_step]' do
      expect(called.result[:first_step]).to eq 'result of first step'
      expect(called.result[:second_step]).to eq 'result of second step'
      expect(called.result[:third_step]).to eq({'result of third step' => 'works'})
    end
  end

  context 'Step fails before the final step' do
    let(:called){ StepFails.call({param_1: 1}) }

    it 'Returns fail' do
      expect(called.success).to eq false
    end

    it 'Final step does not get called' do
      allow_any_instance_of(StepFails).to receive(:first_step).and_return(OrchestratedService::Feedback.new(result: 'successful step'))
      allow_any_instance_of(StepFails).to receive(:second_step).and_return(OrchestratedService::Feedback.new(success: false, result: 'failed step'))
      expect_any_instance_of(StepFails).not_to receive :third_step
      called
    end

    it 'Returns the result of the failed step in .result[:fail]' do
      expect(called.result[:fail]).to eq 'result of second step'
    end

    it 'Returns the result of each step called in .result[:name_of_step]' do
      expect(called.result[:first_step]).to eq 'result of first step'
      expect(called.result[:second_step]).to eq 'result of second step'
    end
  end

  context 'Each step has access to the results of previous steps' do
    let!(:called){ UsesPreviousResults.call({param_1: 1}) }

    it 'Can use the previous results' do
      expect(called.result[:success]).to eq 'result of first step result of second step result of third step'
    end
  end

  context 'A step can defer to a service that itself uses steps' do
    context 'The inner steps succeed' do
      let!(:called){ NestedStepsSuccess.call({param_1: 1})}

      it 'Returns success' do
        expect(called.success).to eq true
      end

      it 'The step that calls the inner steps contains each result from the inner steps' do
        expect(called.result[:third_step][:first_step]).to eq 'result of first step'
        expect(called.result[:third_step][:second_step]).to eq 'result of second step'
        expect(called.result[:third_step][:third_step]).to eq({'result of third step' => 'works'})
      end

      it 'If the step that calls the inner steps is the final step, the final inner step result is set to .result[:success]' do
        expect(called.result[:success]).to eq({'result of third step' => 'works'})
      end
    end

    context 'An inner step fails' do
      let!(:called){ NestedStepsFail.call({param_1: 1})}

      it 'Returns fail' do
        expect(called.success).to eq false
      end

      it 'The step that calls the inner steps contains each result from the inner steps' do
        expect(called.result[:second_step][:first_step]).to eq 'result of first step'
        expect(called.result[:second_step][:second_step]).to eq 'result of second step'
      end

      it 'The result of the failing inner step becomes .result[:fail]' do
        expect(called.result[:fail]).to eq('result of second step')
      end
    end
  end

  context 'A step can return a soft stop which prevents the next step but does not create failure' do
    let!(:called){ NestedSoftStop.call({param_1: 1}) }

    it 'Returns success' do
      expect(called.success).to eq true
    end

    it 'Gets to the final step of the parent steps' do
      expect(called.result[:success]).to eq 'result of third step'
    end

    it 'Within the nested steps the steps stop at the soft stop' do
      expect(called.result[:second_step][:success]).to eq 'result of soft stop'
    end
  end

end
