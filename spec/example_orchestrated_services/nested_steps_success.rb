require_relative 'all_steps_succeed'

class NestedStepsSuccess < OrchestratedService::Service

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
    OrchestratedService::Feedback.new(result: 'result of second step')
  end

  def third_step
    AllStepsSucceed.call(params)
  end

end
