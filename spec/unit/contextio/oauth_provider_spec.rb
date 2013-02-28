require 'spec_helper'
require 'contextio/oauth_provider'

describe ContextIO::OAuthProvider do
  let(:api) { double('API', url_for: 'url from api') }

  describe ".new" do
    subject { ContextIO::OAuthProvider.new(api, resource_url: 'bar', baz: 'bot') }

    it "takes an api handle" do
      expect(subject.api).to eq(api)
    end

    it "assigns instance variables for hash arguments" do
      expect(subject.instance_variable_get('@resource_url')).to eq('bar')
      expect(subject.instance_variable_get('@baz')).to eq('bot')
    end

    context "with a provider_consumer_key passed in" do
      it "doesn't raise an error" do
        expect { ContextIO::OAuthProvider.new(api, provider_consumer_key: 'foo') }.to_not raise_error
      end
    end

    context "with neither a provider_consumer_key nor a resource_url passed in" do
      it "raises an ArgumentError" do
        expect { ContextIO::OAuthProvider.new(api, foo: 'bar') }.to raise_error(ArgumentError)
      end
    end
  end

  describe "#resource_url" do
    context "when input at creation" do
      subject { ContextIO::OAuthProvider.new(api, resource_url: 'http://example.com') }

      it "uses the input URL" do
        expect(subject.resource_url).to eq('http://example.com')
      end
    end

    context "when not input at creation" do
      subject { ContextIO::OAuthProvider.new(api, provider_consumer_key: '1234') }

      it "asks the api for a URL" do
        api.should_receive(:url_for).with(subject)

        subject.resource_url
      end
    end
  end

  describe "#provider_consumer_key" do
    context "when input at creation" do
      subject { ContextIO::OAuthProvider.new(api, provider_consumer_key: '1234') }

      it "uses the input key" do
        api.should_not_receive(:request)

        expect(subject.provider_consumer_key).to eq('1234')
      end
    end

    context "when not input at creation" do
      subject { ContextIO::OAuthProvider.new(api, resource_url: 'http://example.com/hitme') }

      it "loads it from the API" do
        api.should_receive(:request).with(
          :get,
          'http://example.com/hitme'
        ).and_return({
          'provider_consumer_key' => 'baphoo'
        })

        expect(subject.provider_consumer_key).to eq('baphoo')
      end
    end
  end

  describe "#provider_consumer_secret" do
    context "when input at creation" do
      subject { ContextIO::OAuthProvider.new(api, provider_consumer_key: '1234', provider_consumer_secret: '0987') }

      it "uses the input provider_consumer_secret" do
        api.should_not_receive(:request)

        expect(subject.provider_consumer_secret).to eq('0987')
      end
    end

    context "when not input at creation" do
      subject { ContextIO::OAuthProvider.new(api, provider_consumer_key: '1234') }

      it "loads it from the API" do
        api.should_receive(:request).with(:get, anything).and_return({ 'provider_consumer_secret' => '1029' })
        expect(subject.provider_consumer_secret).to eq('1029')
      end
    end
  end

  describe "#type" do
    context "when input at creation" do
      subject { ContextIO::OAuthProvider.new(api, provider_consumer_key: '1234', type: 'GMAIL') }

      it "uses the input type" do
        api.should_not_receive(:request)

        expect(subject.type).to eq('GMAIL')
      end
    end

    context "when not input at creation" do
      subject { ContextIO::OAuthProvider.new(api, provider_consumer_key: '1234') }

      it "loads it from the API" do
        api.should_receive(:request).with(:get, anything).and_return({ 'type' => 'GOOGLEAPPSMARKETPLACE' })
        expect(subject.type).to eq('GOOGLEAPPSMARKETPLACE')
      end
    end
  end
end
