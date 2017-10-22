module OrchestratedService

  class Feedback
    attr_reader :success, :result, :soft_stop

    def initialize(success: true, result: nil, soft_stop: nil)
      @success = success
      @result = result
      @soft_stop = soft_stop
      check_values
    end

    private

    def check_values
      unless success.is_a?(TrueClass) || success.is_a?(FalseClass)
        raise Errors::InvalidFeedbackError.new('Invalid success passed to Feedback - must be true or false')
      end
      unless soft_stop.is_a?(TrueClass) or soft_stop.nil?
        raise Errors::InvalidFeedbackError.new('Invalid soft_stop passed to Feedback - must be nil or true')
      end
    end
  end

end
