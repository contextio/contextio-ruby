require 'spec_helper'
require 'contextio/api'

describe ContextIO::API do
  describe ".version" do
    subject { ContextIO::API }

    it "uses API version 2.0" do
      expect(subject.version).to eq('2.0')
    end
  end

  describe "#version" do
    context "without version change" do
      subject { ContextIO::API.new(nil, nil) }

      it "uses API version 2.0" do
        expect(subject.version).to eq('2.0')
      end
    end

    context "with version change" do
      subject { ContextIO::API.new(nil, nil) }

      it "changes the API version used" do
        subject.version = '1.1'
        expect(subject.version).to eq('1.1')
      end
    end
  end

  describe ".base_url" do
    subject { ContextIO::API }

    it "is https://api.context.io" do
      expect(subject.base_url).to eq('https://api.context.io')
    end
  end

  describe "#base_url" do
    context "without base_url change" do
      subject { ContextIO::API.new(nil, nil) }

      it "is https://api.context.io" do
        expect(subject.base_url).to eq('https://api.context.io')
      end
    end

    context "with base_url change" do
      subject { ContextIO::API.new(nil, nil) }

      it "changes the base_url" do
        subject.base_url = 'https://api.example.com'
        expect(subject.base_url).to eq('https://api.example.com')
      end
    end
  end

  describe ".new" do
    subject { ContextIO::API.new('test_key', 'test_secret', {a:'b'}) }

    it "takes a key" do
      expect(subject.key).to eq('test_key')
    end

    it "takes a secret" do
      expect(subject.secret).to eq('test_secret')
    end

    it "takes an option hash" do
      expect(subject.opts).to eq(a:'b')
    end
  end

  describe "#path" do
    context "without params and default version" do
      subject { ContextIO::API.new(nil, nil).path('test_command') }

      it "puts the command in the path" do
        expect(subject).to eq('/2.0/test_command')
      end
    end

    context "without params and version change" do
      subject { ContextIO::API.new(nil, nil) }

      it "puts the command in the path" do
        subject.version = '2.5'
        expect(subject.path('test_command')).to eq('/2.5/test_command')
      end
    end

    context "with params" do
      subject { ContextIO::API.new(nil, nil).path('test_command', foo: 1, bar: %w(a b c)) }

      it "URL encodes the params" do
        expect(subject).to eq('/2.0/test_command?foo=1&bar=a%2Cb%2Cc')
      end
    end

    context "with a full URL" do
      subject { ContextIO::API.new(nil, nil).path('https://api.context.io/2.0/test_command') }

      it "strips out the command" do
        expect(subject).to eq('/2.0/test_command')
      end
    end

    context "with a full URL and version and base_url change" do
      subject { ContextIO::API.new(nil, nil) }

      it "strips out the command" do
        subject.version = '2.5'
        subject.base_url = 'https://api.example.com'
        expect(subject.path('https://api.example.com/2.5/test_command')).to eq('/2.5/test_command')
      end
    end
  end

  describe "#request" do
    subject { ContextIO::API.new(nil, nil).request(:get, 'test') }

    context "with a good response" do
      before do
        FakeWeb.register_uri(
          :get,
          'https://api.context.io/2.0/test',
          body: JSON.dump('a' => 'b', 'c' => 'd')
        )
      end

      it "parses the JSON response" do
        expect(subject).to eq('a' => 'b', 'c' => 'd')
      end
    end

    context "with a bad response that has a body" do
      before do
        FakeWeb.register_uri(
          :get,
          'https://api.context.io/2.0/test',
          status: ['400', 'Bad Request'],
          body: JSON.dump('type' => 'error', 'value' => 'nope')
        )
      end

      it "raises an API error with the body message" do
        expect { subject }.to raise_error(ContextIO::API::Error, 'nope')
      end
    end

    context "with a bad response that has no body" do
      before do
        FakeWeb.register_uri(
          :get,
          'https://api.context.io/2.0/test',
          status: ['400', 'Bad Request']
        )
      end

      it "raises an API error with the header message" do
        expect { subject }.to raise_error(ContextIO::API::Error, 'Bad Request')
      end
    end
  end

  describe ".url_for" do
    it "delegates to ContextIO::API::URLBuilder" do
      expect(ContextIO::API::URLBuilder).to receive(:url_for).with('foo')

      ContextIO::API.url_for('foo')
    end
  end

  describe "#url_for" do
    subject { ContextIO::API.new('test_key', 'test_secret') }

    it "delegates to the class" do
      expect(ContextIO::API).to receive(:url_for).with('foo')

      subject.url_for('foo')
    end
  end
end
