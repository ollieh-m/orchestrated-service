module OrchestratedService
  module Errors

    class InvalidWrapperError < StandardError
      attr_reader :wrapper

      def initialize(msg="Invalid wrapper", wrapper=nil)
        @wrapper = wrapper
        msg += " - must be one of #{Configuration::PERMITTED_WRAPPERS.join(' or ')}"
        super(msg)
      end
    end

  end
end
