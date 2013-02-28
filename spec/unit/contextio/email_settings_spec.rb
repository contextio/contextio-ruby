require 'spec_helper'
require 'contextio/email_settings'

describe ContextIO::EmailSettings do
  let(:api) { double('API') }

  subject { ContextIO::EmailSettings.new(api, 'email@email.com') }

  describe ".new" do
    context "without a source type passed in" do
      it "takes an api handle" do
        expect(subject.api).to eq(api)
      end

      it "takes an email address" do
        expect(subject.email).to eq('email@email.com')
      end

      it "defaults the source type to 'IMAP'" do
        expect(subject.source_type).to eq('IMAP')
      end
    end

    context "with a source type passed in" do
      subject { ContextIO::EmailSettings.new(api, 'email@email.com', 'FOO') }

      it "takes a source type argument" do
        expect(subject.source_type).to eq('FOO')
      end
    end
  end

  describe "#resource_url" do
    it "builds the right url" do
      expect(subject.resource_url).to eq('discovery')
    end
  end

  describe "#documentation" do
    it "fetches it from the api" do
      api.should_receive(:request).with(:get, anything, anything).and_return({ 'documentation' => ['foo', 'bar'] })
      expect(subject.documentation).to eq(['foo', 'bar'])
    end
  end

  describe "#found?" do
    it "fetches it from the api" do
      api.should_receive(:request).with(:get, anything, anything).and_return({ 'found' => true })
      expect(subject).to be_found
    end
  end

  describe "#type" do
    it "fetches it from the api" do
      api.should_receive(:request).with(:get, anything, anything).and_return({ 'type' => 'gmail' })
      expect(subject.type).to eq('gmail')
    end
  end

  describe "#server" do
    it "fetches it from the api" do
      api.should_receive(:request).with(:get, anything, anything).and_return({ 'imap' => { 'server' => 'imap.gmail.com' }})
      expect(subject.server).to eq('imap.gmail.com')
    end
  end

  describe "#username" do
    it "fetches it from the api" do
      api.should_receive(:request).with(:get, anything, anything).and_return({ 'imap' => { 'username' => 'ben' }})
      expect(subject.username).to eq('ben')
    end
  end

  describe "#port" do
    it "fetches it from the api" do
      api.should_receive(:request).with(:get, anything, anything).and_return({ 'imap' => { 'port' => 993 }})
      expect(subject.port).to eq(993)
    end
  end

  describe "#oauth?" do
    it "fetches it from the api" do
      api.should_receive(:request).with(:get, anything, anything).and_return({ 'imap' => { 'oauth' => false }})
      expect(subject).to_not be_oauth
    end
  end

  describe "#use_ssl?" do
    it "fetches it from the api" do
      api.should_receive(:request).with(:get, anything, anything).and_return({ 'imap' => { 'use_ssl' => false }})
      expect(subject).to_not be_use_ssl
    end
  end

  describe "#fetch_attributes" do
    before do
      api.stub(:request).with(:get, anything, anything).and_return({ 'foo' => 'bar' })
    end

    it "defines a getter if one doesn't already exist" do
      subject.send(:fetch_attributes)

      expect(subject.foo).to eq('bar')
    end

    it "hits the right URL" do
      api.should_receive(:request).with(:get, 'discovery', 'email' => 'email@email.com', 'source_type' => 'IMAP')

      subject.send(:fetch_attributes)
    end
  end
end
