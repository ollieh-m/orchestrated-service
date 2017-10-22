module OrchestratedService
  module Errors

    class InvalidFeedbackError < StandardError
      def initialize(msg="Invalid feedback")
        super(msg)
      end
    end

  end
end
