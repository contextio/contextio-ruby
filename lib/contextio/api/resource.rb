require_relative 'association_helpers'

class ContextIO
  class API
    # When `include`d into a class, this module provides some helper methods for
    # various things a singular resource will need or find useful.
    module Resource
      # (see ContextIO#api)
      attr_reader :api

      # @private
      #
      # For internal use only. Users of this gem shouldn't be calling this
      # directly.
      #
      # @param [API] api A handle on the Context.IO API.
      # @param [Hash{String, Symbol => String, Numeric, Boolean}] options A Hash
      #   of attributes describing the resource.
      def initialize(api, options = {})
        validate_options(options)

        @api = api

        options.each do |key, value|
          key = key.to_s.gsub('-', '_')

          if self.class.associations.include?(key.to_sym) && value.is_a?(Array)
            association_class = ContextIO::API::AssociationHelpers.class_for_association_name(key.to_sym)

            value = association_class.new(api, self.class.association_name => self, attribute_hashes: value)
          end

          instance_variable_set("@#{key}", value)

          unless self.respond_to?(key)
            define_singleton_method(key) do
              instance_variable_get("@#{key}")
            end
          end
        end
      end

      # @!attribute [r] resource_url
      # @return [String] The URL that will fetch attributes from the API.
      def resource_url
        @resource_url ||= api.url_for(self)
      end

      # Deletes the resource.
      #
      # @return [Boolean] Whether the deletion worked or not.
      def delete
        api.request(:delete, resource_url)['success']
      end

      # @!attribute [r] api_attributes
      # @return [{String => Numeric, String, Hash, Array, Boolean}] The
      #   attributes returned from the API as a Hash. If it hasn't been
      #   populated, it will ask the API and populate it.
      def api_attributes
        @api_attributes ||= fetch_attributes
      end

      # @!attribute [r] primary_key
      # @return [String, Symbol] The name of the key used to build the resource
      #   URL.
      def primary_key
        self.class.primary_key
      end

      private

      # Make sure a Resource has the declarative syntax handy.
      def self.included(other_mod)
        other_mod.extend(DeclarativeClassSyntax)
      end

      # Raises ArgumentError unless the primary key or the resource URL is
      # supplied. Use this to ensure that the initializer has or can build the
      # right URL to fetch its self.
      #
      # @param [Hash] options_hash The hash of options to validate.
      def validate_options(options_hash)
        required_keys = ['resource_url', :resource_url]

        unless self.primary_key.nil?
          required_keys << primary_key.to_s
          required_keys << primary_key.to_sym
        end

        if (options_hash.keys & required_keys).empty?
          raise ArgumentError, "Required option missing. Make sure you have either resource_url or #{primary_key}."
        end
      end

      # Fetches attributes from the API for the resource. Relies on having a
      # handle on a `ContextIO::API` via an `api` method and on a `resource_url`
      # method that returns the path for the resource.
      #
      # Defines getter methods for any attributes that come back and don't
      # already have them. This way, if the API expands, the gem will still let
      # users get attributes we didn't explicitly declare as lazy.
      #
      # @return [{String => Numeric, String, Hash, Array, Boolean}] The
      #   attributes returned from the API as a Hash. If it hasn't been
      #   populated, it will ask the API and populate it.
      def fetch_attributes
        api.request(:get, resource_url).inject({}) do |memo, (key, value)|
          key = key.to_s.gsub('-', '_')

          unless respond_to?(key)
            self.define_singleton_method(key) do
              value
            end
          end

          memo[key] = value

          memo
        end
      end

      # This module contains helper methods for `API::Resource`s' class
      # definitions. It gets `extend`ed into a class when `API::Resource` is
      # `include`d.
      module DeclarativeClassSyntax
        def primary_key
          @primary_key
        end

        # @!attribute [r] association_name
        #   @return [Symbol] The association name registered for this resource.
        def association_name
          @association_name
        end

        # @!attribute [r] associations
        #   @return [Array<String] An array of the belong_to associations for
        #     the collection
        def associations
          @associations ||= []
        end

        private

        # Declares the primary key used to build the resource URL. Consumed by
        # `Resource#validate_options`.
        #
        # @param [String, Symbol] key Primary key name.
        def primary_key=(key)
          @primary_key = key
        end

        # Declares the association name for the resource.
        #
        # @param [String, Symbol] association_name The name.
        def association_name=(association_name)
          @association_name = association_name.to_sym
          ContextIO::API::AssociationHelpers.register_resource(self, @association_name)
        end

        # Declares a list of attributes to be lazily loaded from the API. Getter
        # methods are written for each attribute. If the user asks for one and
        # the object in question doesn't have it already, then it will look for
        # it in the api_attributes Hash.
        #
        # @example an example of the generated methods
        #   def some_attribute
        #     return @some_attribute if instance_variable_defined?(@some_attribute)
        #     api_attributes["some_attribute"]
        #   end
        #
        # @param [Array<String, Symbol>] attributes Attribute names.
        def lazy_attributes(*attributes)
          attributes.each do |attribute_name|
            define_method(attribute_name) do
              return instance_variable_get("@#{attribute_name}") if instance_variable_defined?("@#{attribute_name}")
              api_attributes[attribute_name.to_s]
            end
          end
        end

        # Declares that this resource is related to a single instance of another
        # resource. This related resource will be lazily created as it can be,
        # but in some cases may cause an API call.
        #
        # @param [Symbol] association_name The name of the association for the
        #   class in question. Singular classes will have singular names
        #   registered. For instance, :message should reger to the Message
        #   resource.
        def belongs_to(association_name)
          define_method(association_name) do
            if instance_variable_defined?("@#{association_name}")
              instance_variable_get("@#{association_name}")
            else
              association_attrs = api_attributes[association_name.to_s]
              association_class = ContextIO::API::AssociationHelpers.class_for_association_name(association_name)

              if association_attrs && !association_attrs.empty?
                instance_variable_set("@#{association_name}", association_class.new(api, association_attrs))
              else
                nil
              end
            end
          end

          associations << association_name.to_sym
        end

        # Declares that this resource is related to a collection of another
        # resource. These related resources will be lazily created as they can
        # be, but in some cases may cause an API call.
        #
        # @param [Symbol] association_name The name of the association for the
        #   class in question. Collection classes will have plural names
        #   registered. For instance, :messages should reger to the
        #   MessageCollection resource.
        def has_many(association_name)
          define_method(association_name) do
            association_class = ContextIO::API::AssociationHelpers.class_for_association_name(association_name)

            instance_variable_get("@#{association_name}") ||
              instance_variable_set(
                "@#{association_name}",
                association_class.new(
                  api,
                  self.class.association_name => self,
                  attribute_hashes: api_attributes[association_name.to_s]
                )
              )
          end

          associations << association_name.to_sym
        end
      end
    end
  end
end
