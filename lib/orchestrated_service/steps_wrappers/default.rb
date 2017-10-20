module OrchestratedService
  module StepsWrappers

    class Default
      def self.perform(&block)
        block.call
      end
    end

  end
end
