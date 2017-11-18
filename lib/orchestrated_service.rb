require "orchestrated_service/version"
require "orchestrated_service/steps_wrappers/active_record"
require "orchestrated_service/steps_wrappers/default"
require "orchestrated_service/errors/failed_step_error"
require "orchestrated_service/errors/invalid_wrapper_error"
require "orchestrated_service/errors/invalid_feedback_error"
require "orchestrated_service/feedback"
require "orchestrated_service/failure"
require "orchestrated_service/standard_failure"
require "orchestrated_service/configuration"
require "orchestrated_service/orchestrate"
require "orchestrated_service/service"

module OrchestratedService
  def self.configure
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.configure
    yield(configuration)
  end

  def self.reset
    @configuration = Configuration.new
  end
end
