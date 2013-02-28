require 'spec_helper'
require 'contextio/api/url_builder'

describe ContextIO::API::URLBuilder do
  let(:api) { double('api') }

  describe "#url_for" do
    subject { ContextIO::API::URLBuilder.url_for(resource) }

    context "when passed an unregistered class" do
      let(:resource) { "String isn't registered."}

      it "raises an exception" do
        expect { subject }.to raise_exception(ContextIO::API::URLBuilder::Error)
      end
    end

    context "when passed a ConnectToken" do
      context "with an account" do
        let(:account) { double('account', id: 'account_id') }
        let(:resource) { ContextIO::ConnectToken.new(api, token: 'token', account: account) }

        it { should eq('connect_tokens/token') }
      end

      context "without an account" do
        let(:resource) { ContextIO::ConnectToken.new(api, token: 'token') }

        it { should eq('connect_tokens/token') }
      end
    end

    context "when passed a ConnectTokenCollection" do
      context "with an account" do
        let(:account) { double('account', id: 'account_id') }
        let(:resource) { ContextIO::ConnectTokenCollection.new(api, account: account) }

        it { should eq('accounts/account_id/connect_tokens') }
      end

      context "without an account" do
        let(:resource) { ContextIO::ConnectTokenCollection.new(api) }

        it { should eq('connect_tokens') }
      end
    end

    context "when passed an OAuthProvider" do
      let(:resource) { ContextIO::OAuthProvider.new(api, provider_consumer_key: 'provider_consumer_key') }

      it { should eq('oauth_providers/provider_consumer_key') }
    end

    context "when passed an OAuthProviderCollection" do
      let(:resource) { ContextIO::OAuthProviderCollection.new(api) }

      it { should eq('oauth_providers') }
    end

    context "when passed an EmailSettings" do
      let(:resource) { ContextIO::EmailSettings.new(api, 'email') }

      it { should eq('discovery') }
    end

    context "when passed an Account" do
      let(:resource) { ContextIO::Account.new(api, id: 'account_id') }

      it { should eq('accounts/account_id') }
    end

    context "when passed an AccountCollection" do
      let(:resource) { ContextIO::AccountCollection.new(api) }

      it { should eq('accounts') }
    end
  end
end
