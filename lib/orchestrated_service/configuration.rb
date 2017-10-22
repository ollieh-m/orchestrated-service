module OrchestratedService

  class Configuration

    PERMITTED_WRAPPERS = [
      StepsWrappers::Default,
      StepsWrappers::ActiveRecord
    ]

    attr_reader :wrapper

    def initialize
      @wrapper = StepsWrappers::Default
    end

    def wrapper=(wrapper)
      if PERMITTED_WRAPPERS.include?(wrapper)
        @wrapper = wrapper
      else
        raise Errors::InvalidWrapperError
      end
    end

  end

end
