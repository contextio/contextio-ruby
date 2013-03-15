require 'contextio/api/association_helpers'

class ContextIO
  class EmailAddress
    def self.association_name
      :email_address
    end
    ContextIO::API::AssociationHelpers.register_resource(self, :email_address)

    # (see ContextIO#api)
    attr_reader :api, :account, :email, :validated, :primary
    private :validated, :primary
    #
    # @private
    #
    # For internal use only. Users of this gem shouldn't be calling this
    # directly.
    #
    # @param [API] api A handle on the Context.IO API.
    # @param [Hash{String, Symbol => String, Numeric, Boolean}] options A Hash
    #   of attributes describing the resource.
    def initialize(api, options = {})
      @api = api
      @account = options.delete(:account) || options.delete('account')

      options.each do |key, value|
        key = key.to_s.gsub('-', '_')

        instance_variable_set("@#{key}", value)

        unless self.respond_to?(key)
          define_singleton_method(key) do
            instance_variable_get("@#{key}")
          end
        end
      end
    end

    def validated?
      !!validated
    end

    def primary?
      !!primary
    end

    def set_primary
      api.request(:post, resource_url, primary: 1)['success']
    end

    def delete
      api.request(:delete, resource_url)['success']
    end
  end
end
