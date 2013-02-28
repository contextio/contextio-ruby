require 'spec_helper'
require 'contextio'

describe ContextIO do
  subject { ContextIO.new(nil, nil) }

  describe ".new" do
    it "creates a new API handle" do
      expect(ContextIO.new(nil, nil).api).to be_a(ContextIO::API)
    end

    it "passes credentials to its API handle" do
      api = ContextIO.new('1234', '0987').api
      expect(api.key).to eq('1234')
      expect(api.secret).to eq('0987')
    end

    it "passes opts to its API handle" do
      api = ContextIO.new('1234', '0987', {a:'b'}).api
      expect(api.opts).to eq(a:'b')
    end
  end

  describe "#oauth_providers" do
    it "returns a new OAuthProviderCollection" do
      expect(subject.oauth_providers).to be_a(ContextIO::OAuthProviderCollection)
    end

    it "passes its API handle to the OAuthProviderCollection" do
      expect(subject.oauth_providers.api).to eq(subject.api)
    end
  end

  describe "#accounts" do
    it "returns a new AccountCollection" do
      expect(subject.accounts).to be_a(ContextIO::AccountCollection)
    end

    it "passes its API handle to the AccountCollection" do
      expect(subject.accounts.api).to eq(subject.api)
    end
  end

  describe "#connect_tokens" do
    it "returns a new ConnectTokenCollection" do
      expect(subject.connect_tokens).to be_a(ContextIO::ConnectTokenCollection)
    end

    it "passes its API handle to the ConnectTokenCollection" do
      expect(subject.connect_tokens.api).to eq(subject.api)
    end
  end

  describe "#email_settings_for" do
    subject { ContextIO.new(nil, nil).email_settings_for('email@address.com') }

    it "returns a new EmailSettings" do
      expect(subject).to be_a(ContextIO::EmailSettings)
    end

    it "passes its API handle to the EmailSettings" do
      expect(subject.api).to eq(subject.api)
    end

    it "passes the email address to the EmailSettings" do
      expect(subject.email).to eq('email@address.com')
    end
  end
end
