require 'spec_helper'
require 'contextio/oauth_provider_collection'

describe ContextIO::OAuthProviderCollection do
  let(:api) { double('API', url_for: 'url from api') }

  subject { ContextIO::OAuthProviderCollection.new(api) }

  describe "#create" do
    before do
      api.stub(:request).with(:post, anything, anything).and_return({ provider_consumer_key: 'test_key' })
    end

    it "posts to the api" do
      api.should_receive(:request).with(
        :post,
        'url from api',
        type: 'GMAIL',
        provider_consumer_key: 'test_key',
        provider_consumer_secret: 'test_secret'
      )

      subject.create('GMAIL', 'test_key', 'test_secret')
    end

    it "doesn't make any more API requests than it needs to" do
      api.should_receive(:request).exactly(:once)

      subject.create('GMAIL', 'test_key', 'test_secret')
    end

    it "returns an OAuthProvider" do
      expect(subject.create('GMAIL', 'test_key', 'test_secret')).to be_a(ContextIO::OAuthProvider)
    end
  end
end
