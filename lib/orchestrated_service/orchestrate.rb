module OrchestratedService
  module Orchestrate
    def wrapper
      StepsWrappers::Default
    end

    def steps(*steps)
      @result = {}

      begin
        wrapper.perform do
          # perform each step and update @result with the result from the step
          # if a step fails, stop running through steps
          # and raise an error to rollback database commits from previous steps
          steps.each_with_index do |step, index|
            feedback = send(step)
            @result[step] = feedback.result
            unless feedback.success
              raise Errors::FailedStepError.new("Failed step", step)
            end
            if feedback.soft_stop
              steps = steps[0..index]
              break
            end
          end
        end
        # if the steps succeed save the final result as @result[:success]
        # if the final step result is already a result hash, bubble up that result's success
        @result[:success] = bubble_up_success_from_result @result[steps.last]
        Feedback.new(success: true, result: @result)
      rescue Errors::FailedStepError => e
        # if a step fails, assign a @result[:fail] with the result of the failed step
        # and return failure with the results of previous steps
        @result[:fail] = bubble_up_fail_from_result @result[e.step]
        return Feedback.new(success: false, result: @result)
      end
    end

    def bubble_up_fail_from_result(result)
      if result.is_a?(Hash) && result[:fail]
        result[:fail]
      else
        result
      end
    end

    def bubble_up_success_from_result(result)
      if result.is_a?(Hash) && result[:success]
        result[:success]
      else
        result
      end
    end
  end
end
