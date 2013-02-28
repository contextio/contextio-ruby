require_relative 'association_helpers'

class ContextIO
  class API
    # When `include`d into a class, this module provides some helper methods for
    # various things a collections of resources will need or find useful.
    module ResourceCollection
      include Enumerable

      # (see ContextIO#api)
      attr_reader :api

      # @!attribute [r] where_constraints
      #   A Hash of the constraints limiting this collection of resources.
      attr_reader :where_constraints

      # @private
      #
      # For internal use only. Users of this gem shouldn't be calling this
      # directly.
      #
      # @param [API] api A handle on the Context.IO API.
      # @param [Hash] options Optional params for the collection.
      # @option options [Hash{Symbol => String, Numeric}] :where Where
      #   constraints that limit the resources that belong to this collection.
      # @option options [Array<Hash>] :attribute_hashes An array of hashes
      #   describing the resources in this collection.
      def initialize(api, options={})
        @api = api
        @where_constraints = options[:where] || {}
        @attribute_hashes = options[:attribute_hashes]

        self.class.associations.each do |association_name|
          instance_variable_set("@#{association_name}", options[association_name.to_sym])
        end
      end

      # @!attribute [r] resource_url
      # @return [String] The URL that will fetch attributes from the API.
      def resource_url
        @resource_url ||= api.url_for(self)
      end

      # Iterates over the resources in question.
      #
      # @example
      #   contextio.connect_tokens.each do |connect_token|
      #     puts connect_token.email
      #   end
      def each(&block)
        attribute_hashes.each do |attribute_hash|
          yield resource_class.new(api, attribute_hash.merge(associations_hash))
        end
      end

      # Returns the number of elements in self. May be zero.
      #
      # @note Calling this method will load the collection if not already loaded.
      def size
        attribute_hashes.size
      end
      alias :length :size
      alias :count :size

      # Returns true if self contains no elements.
      #
      # @note Calling this method will load the collection if not already loaded.
      def empty?
        size == 0
      end

      # Specify one or more constraints for limiting resources in this
      # collection. See individual classes for the list of valid constraints.
      # Not all collections have valid where constraints at all.
      #
      # This can be chained at need and doesn't actually cause the API to get
      # hit until some iterator is called like `#each`.
      #
      # @example
      #   accounts = contextio.accounts
      #   accounts = accounts.where(email: 'some@email.com')
      #   accounts = accounts.where(status: 'OK')
      #
      #   accounts.each do |account|
      #     # API gets hit for this call
      #   end
      #
      # @param [Hash{String, Symbol => String, Integer}] constraints A Hash
      #   mapping keys to the desired limiting values.
      def where(constraints)
        self.class.new(api, associations_hash.merge(where: where_constraints.merge(constraints)))
      end

      # Returns a resource with the given key.
      #
      # This is a lazy method, making no requests. When you try to access
      # attributes on the object, or otherwise interact with it, it will actually
      # make requests.
      #
      # @example
      #   provider = contextio.oauth_providers['1234']
      #
      # @param [String] key The Provider Consumer Key for the
      #   provider you want to interact with.
      def [](key)
        resource_class.new(api, associations_hash.merge(resource_class.primary_key => key))
      end

      private

      # @!attribute [r] attribute_hashes
      #   @return [Array<Hash>] An array of attribute hashes that describe, at
      #     least partially, the objects in this collection.
      def attribute_hashes
        @attribute_hashes ||= api.request(:get, resource_url, where_constraints)
      end

      # @!attribute [r] associations_hash
      #   @return [Hash{Symbol => Resource}] A hash of association names to the
      #     associated resource of that type.
      def associations_hash
        @associations_hash ||= self.class.associations.inject({}) do |memo, association_name|
          memo[association_name.to_sym] = self.send(association_name)
          memo
        end
      end

      # Make sure a ResourceCollection has the declarative syntax handy.
      def self.included(other_mod)
        other_mod.extend(DeclarativeClassSyntax)
      end

      # This module contains helper methods for `API::ResourceCollection`s'
      # class definitions. It gets `extend`ed into a class when
      # `API::ResourceCollection` is `include`d.
      module DeclarativeClassSyntax
        # @!attribute [r] associations
        #   @return [Array<String] An array of the belong_to associations for
        #     the collection
        def associations
          @associations ||= []
        end

        # @!attribute [r] association_name
        #   @return [Symbol] The association name registered for this resource.
        def association_name
          @association_name
        end

        private

        # Declares which class the `ResourceCollection` is intended to wrap. For
        # best results, this should probably be a `Resource`. It defines an
        # accessor for this class on instances of the collection, which is
        # private. Make sure your collection class has required the file with
        # the defeniiton of the class it wraps.
        #
        # @param [Class] klass The class that the collection, well, collects.
        def resource_class=(klass)
          define_method(:resource_class) do
            klass
          end
        end

        # Declares which class, if any, the collection belongs to. It defines an
        # accessor for the belonged-to object.
        #
        # @param [Symbol] association_name The name of the association for the
        #   class in question. Singular classes will have singular names
        #   registered. For instance, :message should reger to the Message
        #   resource.
        def belongs_to(association_name)
          define_method(association_name) do
            instance_variable_get("@#{association_name}")
          end

          associations << association_name
        end

        # Declares the association name for the resource.
        #
        # @param [String, Symbol] association_name The name.
        def association_name=(association_name)
          @association_name = association_name.to_sym
          ContextIO::API::AssociationHelpers.register_resource(self, @association_name)
        end
      end
    end
  end
end
