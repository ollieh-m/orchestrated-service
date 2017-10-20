require "spec_helper"

RSpec.describe OrchestratedService do
  it "has a version number" do
    expect(OrchestratedService::VERSION).not_to be nil
  end
end
