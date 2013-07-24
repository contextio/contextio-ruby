require 'contextio/api/resource'

class ContextIO
  class Source
    include ContextIO::API::Resource

    self.primary_key = :label
    self.association_name = :source

    belongs_to :account
    has_many :folders

    lazy_attributes :server, :label, :username, :port, :authentication_type,
                    :status, :service_level, :sync_period, :use_ssl, :type
    private :use_ssl

    # @!attribute [r] use_ssl?
    #   @return [Boolean] Whether or not this source uses SSL.
    def use_ssl?
      use_ssl
    end

    # Updates the source.
    #
    # @params [Hash{String, Symbol => String}] options You can update the
    #   following: status, sync_period, service_level, password, provider_token,
    #   provider_token_secret, provider_consumer_key. See the Context.IO docs
    #   for more details on these fields.
    def update(options={})
      it_worked = api.request(:post, resource_url, options)['success']

      if it_worked
        options.each do |key, value|
          key = key.to_s.gsub('-', '_')

          instance_variable_set("@#{key}", value)
        end
      end

      it_worked
    end

    def delete
      api.request(:delete, resource_url)['success']
    end

    def sync_data
      return @sync_data if @sync_data

      sync_hashes = api.request(:get, "#{resource_url}/sync")

      @sync_data = ContextIO::SourceSyncData.new(sync_hashes)

      return @sync_data
    end

    def sync!(options={})
      api.request(:post, "#{resource_url}/sync", options)['success']
    end
  end
end
