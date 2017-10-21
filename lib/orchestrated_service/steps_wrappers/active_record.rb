module OrchestratedService
  module StepsWrappers

    class ActiveRecord
      def self.perform(&block)
        ::ActiveRecord::Base.transaction(&block)
      end
    end

  end
end
