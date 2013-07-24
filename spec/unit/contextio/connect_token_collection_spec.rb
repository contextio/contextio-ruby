require 'spec_helper'
require 'contextio/connect_token_collection'

describe ContextIO::ConnectTokenCollection do
  let(:api) { double('API', url_for: 'url from api') }

  subject { ContextIO::ConnectTokenCollection.new(api) }

  describe "#create" do
    before do
      allow(api).to receive(:request).with(:post, anything, anything).and_return({ token: '1234' })
    end

    it "posts to the api" do
      expect(api).to receive(:request).with(
        :post,
        'url from api',
        hash_including(callback_url: 'http://callback.com')
      )

      subject.create('http://callback.com')
    end

    it "doesn't make any more API calls than it needs to" do
      expect(api).to_not receive(:request).with(:get, anything, anything)

      subject.create('http://callback.com')
    end

    it "returns a ConnectToken" do
      expect(subject.create('http://callback.com')).to be_a(ContextIO::ConnectToken)
    end

    it "takes an optional service level" do
      expect(api).to receive(:request).with(
        anything,
        anything,
        hash_including(service_level: 'PRO')
      )

      subject.create('http://callback.com', service_level: 'PRO')
    end

    it "takes an optional email" do
      expect(api).to receive(:request).with(
        anything,
        anything,
        hash_including(email: 'person@email.com')
      )

      subject.create('http://callback.com', email: 'person@email.com')
    end

    it "takes an optional first name" do
      expect(api).to receive(:request).with(
        anything,
        anything,
        hash_including(first_name: 'Bruno')
      )

      subject.create('http://callback.com', first_name: 'Bruno')
    end

    it "takes an optional last name" do
      expect(api).to receive(:request).with(
        anything,
        anything,
        hash_including(last_name: 'Morency')
      )

      subject.create('http://callback.com', last_name: 'Morency')
    end
  end
end
