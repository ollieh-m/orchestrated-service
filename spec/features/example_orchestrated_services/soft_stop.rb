class SoftStop < OrchestratedService::Service

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
    OrchestratedService::Feedback.new(soft_stop: true, result: 'result of soft stop')
  end

  def third_step
    OrchestratedService::Feedback.new(result: 'result of third step')
  end

end
