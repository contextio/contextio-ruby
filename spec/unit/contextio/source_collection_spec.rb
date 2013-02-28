require 'spec_helper'
require 'contextio/source_collection'

describe ContextIO::SourceCollection do
  let(:api) { double('api', url_for: 'url from api') }

  subject { ContextIO::SourceCollection.new(api) }

  describe "#create" do
    before do
      api.stub(:request).with(:post, anything, anything).and_return(
        'success'      => true,
        'resource_url' => 'resource_url'
      )
    end

    it "posts to the api" do
      api.should_receive(:request).with(
        :post,
        'url from api',
        anything
      )

      subject.create('hello@gmail.com', 'imap.email.com', 'hello', true, 993, 'IMAP')
    end

    it "converts boolean to number string for ssl" do
      api.should_receive(:request).with(
        anything,
        anything,
        hash_including('use_ssl' => '1')
      )

      subject.create('hello@gmail.com', 'imap.email.com', 'hello', true, 993, 'IMAP')
    end

    it "converts integer to number string for port" do
      api.should_receive(:request).with(
        anything,
        anything,
        hash_including('port' => '993')
      )

      subject.create('hello@gmail.com', 'imap.email.com', 'hello', true, 993, 'IMAP')
    end

    it "doesn't make any more API calls than it needs to" do
      api.should_not_receive(:request).with(:get, anything, anything)

      subject.create('hello@gmail.com', 'imap.email.com', 'hello', true, 993, 'IMAP')
    end

    it "returns a Source" do
      expect(subject.create('hello@gmail.com', 'imap.email.com', 'hello', true, 993, 'IMAP')).to be_a(ContextIO::Source)
    end
  end
end
