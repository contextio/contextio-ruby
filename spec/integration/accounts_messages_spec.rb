require 'spec_helper'
require 'contextio'

describe "A Message created from an Account" do
  let(:api) { double(:api) }
  let(:account) { ContextIO::Account.new(api, id: '1234', messages: [{}]) }
  let(:message) { account.messages['4321'] }

  it "has a handle back to the account" do
    expect(message.account).to be(account)
  end
end
