module OrchestratedService
  module Errors

    class FailedStepError < StandardError
      attr_reader :step

      def initialize(msg="Failed step", step=nil)
        @step = step
        super(msg)
      end
    end

  end
end
