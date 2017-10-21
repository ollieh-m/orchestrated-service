module OrchestratedService
  module StepsWrappers

    class Default
      def self.perform
        yield
      end
    end

  end
end
