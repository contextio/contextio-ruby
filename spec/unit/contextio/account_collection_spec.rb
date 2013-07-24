require 'spec_helper'
require 'contextio/account_collection'

describe ContextIO::AccountCollection do
  let(:api) { double('API', url_for: 'url from api') }

  subject { ContextIO::AccountCollection.new(api) }

  describe "#create" do
    before do
      allow(api).to receive(:request).with(:post, anything, anything).and_return(
        'success'      => true,
        'id'           => '1234',
        'resource_url' => 'resource_url'
      )
    end

    context "without where constraints" do
      it "requires an email address" do
        expect { subject.create(first_name: 'Bruno') }.to raise_error(ArgumentError)
      end

      it "posts to the api" do
        expect(api).to receive(:request).with(
          :post,
          'url from api',
          hash_including(email: 'hello@email.com')
        )

        subject.create(email: 'hello@email.com')
      end

      it "doesn't make any more API calls than it needs to" do
        expect(api).to_not receive(:request).with(:get, anything, anything)

        subject.create(email: 'hello@email.com')
      end

      it "returns an Account" do
        expect(subject.create(email: 'hello@email.com')).to be_a(ContextIO::Account)
      end

      it "takes an optional first name" do
        expect(api).to receive(:request).with(
          anything,
          anything,
          hash_including(first_name: 'Bruno')
        )

        subject.create(email: 'hello@email.com', first_name: 'Bruno')
      end

      it "takes an optional last name" do
        expect(api).to receive(:request).with(
          anything,
          anything,
          hash_including(last_name: 'Morency')
        )

        subject.create(email: 'hello@email.com', last_name: 'Morency')
      end
    end

    context "with email in the where constraints" do
      subject { ContextIO::AccountCollection.new(api).where(email: 'hello@email.com')}

      it "allows a missing email address" do
        expect { subject.create(first_name: 'Bruno') }.to_not raise_error
      end

      it "uses the email address from the where constraints" do
        expect(api).to receive(:request).with(anything, anything, hash_including(email: 'hello@email.com'))

        subject.create(first_name: 'Bruno')
      end
    end
  end
end
