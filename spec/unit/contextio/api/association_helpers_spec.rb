require 'spec_helper'
require 'contextio/api/association_helpers'

describe "ContextIO::API::AssociationHelpers" do
  subject { ContextIO::API::AssociationHelpers }

  describe ".class_for_association_name" do
    context "when the resource is registered" do
      let(:resource_class) do
        Class.new
      end

      before do
        subject.register_resource(resource_class, :registered)
      end

      it "makes the resource available" do
        expect(subject.class_for_association_name(:registered)).to be(resource_class)
      end
    end

    context "when the resource is NOT registered" do
      it "returns nil" do
        expect(subject.class_for_association_name(:not_registered)).to be_nil
      end
    end
  end
end
