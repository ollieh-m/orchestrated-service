require_relative 'soft_stop'

class NestedSoftStop < OrchestratedService::Service

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
    SoftStop.call(params)
  end

  def third_step
    OrchestratedService::Feedback.new(result: 'result of third step')
  end

end
