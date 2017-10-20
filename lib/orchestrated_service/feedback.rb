module OrchestratedService

  class Feedback
    attr_reader :success, :result, :soft_stop

    def initialize(success: true, result: nil, soft_stop: nil)
      @success = success
      @result = result
      @soft_stop = soft_stop
    end
  end

end
