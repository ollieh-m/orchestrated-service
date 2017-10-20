module OrchestratedService
  class Service

    include Orchestrate

    attr_reader :params, :current_user

    def self.call(params, **args)
      new(params, **args).call
    end

    def initialize(params, **args)
      @params = params
      @current_user = args[:current_user]
    end

  end

end
