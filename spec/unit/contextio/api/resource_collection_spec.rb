require 'spec_helper'
require 'contextio/api/resource_collection'

class SingularHelper
  def initialize(*args); end
  def self.primary_key; 'token'; end
end

class Owner
  def self.primary_key; 'id'; end
  def id; 4; end
  def initialize(*args); end

  ContextIO::API::AssociationHelpers.register_resource(self, :owner)
end

describe ContextIO::API::ResourceCollection do
  let(:api) { double('api', url_for: 'url from api') }

  describe ".resource_class=" do
    let(:helper_class) do
      Class.new do
        include ContextIO::API::ResourceCollection

        self.resource_class = SingularHelper
      end
    end

    subject do
      helper_class.new(api)
    end

    it "makes the class available to instances of the collection" do
      expect(subject.resource_class).to eq(SingularHelper)
    end
  end

  describe ".belongs_to" do
    let(:helper_class) do
      Class.new do
        include ContextIO::API::ResourceCollection

        belongs_to :owner

        self.association_name = :helper_class
        self.resource_class = SingularHelper
      end
    end

    let(:owner) { Owner.new }

    subject { helper_class.new(api, owner: owner) }

    it "makes the belonged-to object available" do
      expect(subject.owner).to eq(owner)
    end
  end

  describe "#api" do
    let(:helper_class) do
      Class.new do
        include ContextIO::API::ResourceCollection
      end
    end

    subject do
      helper_class.new(api)
    end

    it "holds a reference to the api" do
      expect(subject.api).to eq(api)
    end
  end

  describe ".where" do
    let(:helper_class) do
      Class.new do
        include ContextIO::API::ResourceCollection

        belongs_to :owner

        self.resource_class = SingularHelper
      end
    end

    subject do
      helper_class.new(api, owner: :relation)
    end

    it "limits the scope of subsequent #each calls" do
      expect(api).to receive(:request).with(anything, anything, foo: 'bar').and_return([])

      subject.where(foo: 'bar').each { }
    end

    it "returns a new object, not the same one, modified" do
      expect(subject.where(foo: 'bar')).to_not be(subject)
    end

    it "returns a collection object" do
      expect(subject.where(foo: 'bar')).to be_a(helper_class)
    end

    it "makes the constraints available" do
      expect(subject.where(foo: 'bar').where_constraints).to eq(foo: 'bar')
    end

    it "overrides older constraints with newer ones" do
      expect(subject.where(foo: 'bar').where(foo: 'baz').where_constraints).to eq(foo: 'baz')
    end

    it "keeps collection relations from the old to new object" do
      expect(subject.where(foo: 'bar').owner).to eq(subject.owner)
    end
  end

  describe "#each" do
    let(:helper_class) do
      Class.new do
        include ContextIO::API::ResourceCollection

        self.resource_class = SingularHelper
      end
    end

    context "when no attribute hashes are passed in at creation" do
      subject do
        helper_class.new(api)
      end

      before do
        allow(api).to receive(:request).and_return([{key: 'value 1'}, {key: 'value 2'}])
      end

      it "yields instances of the singular resource class" do
        subject.each do |x|
          expect(x).to be_a(SingularHelper)
        end
      end

      it "gets attributes for the resources from the api" do
        expect(api).to receive(:request).exactly(:once).with(:get, 'url from api', {})

        subject.each { }
      end

      it "passes the api to the singular resource instances" do
        expect(SingularHelper).to receive(:new).exactly(:twice).with(api, anything)

        subject.each { }
      end

      it "passes attributes to the singular resource instances" do
        expect(SingularHelper).to receive(:new).exactly(:once).with(anything, key: 'value 1')
        expect(SingularHelper).to receive(:new).exactly(:once).with(anything, key: 'value 2')

        subject.each { }
      end

      context "with a belonged-to resource" do
        let(:helper_class) do
          Class.new do
            include ContextIO::API::ResourceCollection

            belongs_to :owner

            self.resource_class = SingularHelper
          end
        end

        let(:owner) { Owner.new }

        subject do
          helper_class.new(api, owner: owner)
        end

        it "passes the belonged-to resource to the singular resource instances" do
          expect(SingularHelper).to receive(:new).exactly(:twice).with(
            anything,
            hash_including(owner: owner)
          )

          subject.each { }
        end
      end
    end

    context "when attribute hashes are passed in at creation" do
      subject do
        helper_class.new(api, attribute_hashes: [{foo: 'bar'}, {foo: 'baz'}])
      end

      it "yields instances of the singular resource class" do
        subject.each do |x|
          expect(x).to be_a(SingularHelper)
        end
      end

      it "doesn't hit the API" do
        expect(api).to_not receive(:request)

        subject.each { }
      end

      it "passes the api to the singular resource instances" do
        expect(SingularHelper).to receive(:new).exactly(:twice).with(api, anything)

        subject.each { }
      end

      it "passes attributes to the singular resource instances" do
        expect(SingularHelper).to receive(:new).exactly(:once).with(anything, foo: 'bar')
        expect(SingularHelper).to receive(:new).exactly(:once).with(anything, foo: 'baz')

        subject.each { }
      end

      context "with a belonged-to resource" do
        let(:helper_class) do
          Class.new do
            include ContextIO::API::ResourceCollection

            belongs_to :owner

            self.resource_class = SingularHelper
          end
        end

        let(:owner) { Owner.new }

        subject do
          helper_class.new(
            api,
            attribute_hashes: [{foo: 'bar'}, {foo: 'baz'}],
            owner: owner
          )
        end

        it "passes the belonged-to resource to the singular resource instances" do
          expect(SingularHelper).to receive(:new).exactly(:twice).with(
            anything,
            hash_including(owner: owner)
          )

          subject.each { }
        end
      end
    end
  end

  describe "#[]" do
    let(:helper_class) do
      Class.new do
        include ContextIO::API::ResourceCollection

        self.resource_class = SingularHelper
      end
    end

    subject do
      helper_class.new(api)
    end

    it "returns a new instance of the resource class" do
      expect(subject[1234]).to be_a(SingularHelper)
    end

    it "feeds the given key to the resource class" do
      expect(SingularHelper).to receive(:new).with(anything, 'token' => 1234)

      subject[1234]
    end

    it "feeds the api to the resource class" do
      expect(SingularHelper).to receive(:new).with(api, anything)

      subject[1234]
    end

    it "doesn't hit the API" do
      expect(api).to_not receive(:request)

      subject[1234]
    end

    context "with an empty association" do
      let(:helper_class) do
        Class.new do
          include ContextIO::API::ResourceCollection

          belongs_to :owner
          self.resource_class = SingularHelper
        end
      end

      it "doesn't pass a nil association to the resouce class" do
        expect(SingularHelper).to receive(:new).with(api, 'token' => 1234)

        subject[1234]
      end
    end
  end
end
