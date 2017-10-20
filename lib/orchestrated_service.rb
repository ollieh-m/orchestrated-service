require "orchestrated_service/version"
require "orchestrated_service/steps_wrappers/active_record"
require "orchestrated_service/steps_wrappers/default"
require "orchestrated_service/errors/failed_step_error"
require "orchestrated_service/feedback"
require "orchestrated_service/orchestrate"
require "orchestrated_service/service"

module OrchestratedService

  Config = {
    step_wrapper: StepsWrappers::Default
  }

end
