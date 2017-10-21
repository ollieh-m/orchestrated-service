class UsesPreviousResults < OrchestratedService::Service

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
    OrchestratedService::Feedback.new(result: @result[:first_step] + ' result of second step')
  end

  def third_step
    OrchestratedService::Feedback.new(result: @result[:second_step] + ' result of third step')
  end

end
