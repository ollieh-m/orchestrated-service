require_relative 'step_fails'

class NestedStepsFail < OrchestratedService::Service

  def call
    steps(
      :first_step,
      :second_step,
      :third_step
    )
  end

  private

  def first_step
    OrchestratedService::Feedback.new(result: 'result of first step')
  end

  def second_step
    StepFails.call(params)
  end

  def third_step
    OrchestratedService::Feedback.new(result: 'result of third step')
  end

end
