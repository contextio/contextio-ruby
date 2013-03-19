require 'spec_helper'
require 'contextio'

describe "A MessageCollection created from a Folder" do
  let(:api) { double(:api) }
  let(:source) { double(:source, account: 'account') }
  let(:folder) { ContextIO::Folder.new(api, source: source) }
  let(:message_collection) { folder.messages }

  it "has a handle on the right account" do
    expect(message_collection.account).to eq('account')
  end
end
