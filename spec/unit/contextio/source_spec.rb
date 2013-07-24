require 'spec_helper'
require 'contextio/source'

describe ContextIO::Source do
  let(:api) { double('api') }

  subject { ContextIO::Source.new(api, resource_url: 'resource url') }

  describe ".new" do
    context "with a label passed in" do
      it "doesn't raise an error" do
        expect { ContextIO::Source.new(api, label: '1234') }.to_not raise_error
      end
    end

    context "with neither a label nor a resource_url passed in" do
      it "raise an ArgumentError" do
        expect { ContextIO::Source.new(api, foo: 'bar') }.to raise_error(ArgumentError)
      end
    end
  end

  describe "#update" do
    before do
      allow(api).to receive(:request).and_return({'success' => true})
    end

    subject { ContextIO::Source.new(api, resource_url: 'resource_url', sync_period: '1h') }

    it "posts to the api" do
      expect(api).to receive(:request).with(
        :post,
        'resource_url',
        sync_period: '4h'
      )

      subject.update(sync_period: '4h')
    end

    it "updates the object" do
      subject.update(sync_period: '4h')

      expect(subject.sync_period).to eq('4h')
    end

    it "doesn't make any more API calls than it needs to" do
      expect(api).to_not receive(:request).with(:get, anything, anything)

      subject.update(sync_period: '4h')
    end

    it "allows you to send arbitrary arguments to the API" do
      expect(api).to receive(:request).with(:post, anything, {foo: 'bar'})

      subject.update(foo: 'bar')
    end
  end

  describe ".sync!" do
    before do
      allow(api).to receive(:request).and_return({'success' => true})
    end

    subject { ContextIO::Source.new(api, resource_url: 'resource_url', sync_period: '1h') }

    it "syncs to the api" do
      expect(api).to receive(:request).with(
        :post,
        'resource_url/sync',
        {}
      )

      subject.sync!
    end
  end
end
