require 'spec_helper'
require 'contextio/version'

describe ContextIO do
  describe ".version" do
    it "reports its version" do
      expect(ContextIO.version).to_not be_empty
    end
  end
end
