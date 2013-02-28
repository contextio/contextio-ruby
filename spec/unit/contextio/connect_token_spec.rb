require 'spec_helper'
require 'contextio/connect_token'

describe ContextIO::ConnectToken do
  let(:api) { double('API') }

  describe ".new" do
    subject { ContextIO::ConnectToken.new(api, token: '1234', foo: 'bar') }

    it "takes an api handle" do
      expect(subject.api).to eq(api)
    end

    it "assigns instance variables for hash arguments" do
      expect(subject.instance_variable_get('@token')).to eq('1234')
      expect(subject.instance_variable_get('@foo')).to eq('bar')
    end

    context "with a token passed in" do
      it "doesn't raise an error" do
        expect { ContextIO::ConnectToken.new(api, token: '1234') }.to_not raise_error
      end
    end

    context "with neither a provider_token nor a resource_url passed in" do
      it "raises an ArgumentError" do
        expect { ContextIO::ConnectToken.new(api, foo: 'bar') }.to raise_error(ArgumentError)
      end
    end
  end

  describe "#token" do
    context "when input at creation" do
      subject { ContextIO::ConnectToken.new(api, token: '1234') }

      it "uses the input key" do
        api.should_not_receive(:request)

        expect(subject.token).to eq('1234')
      end
    end

    context "when not input at creation" do
      subject { ContextIO::ConnectToken.new(api, resource_url: 'http://example.com/hitme') }

      it "loads it from the API" do
        api.should_receive(:request).with(
          :get,
          'http://example.com/hitme'
        ).and_return({
          'token' => 'baphoo'
        })

        expect(subject.token).to eq('baphoo')
      end
    end
  end
end
