require "spec_helper"

RSpec.describe Teachable do
  it "has a version number" do
    expect(Teachable::VERSION).not_to be nil
  end

  it "does something useful" do
    expect(true).to eq(true)
  end

  it "Order model exists" do
  	expect(described_class::Order.new).to exist
  end
end
