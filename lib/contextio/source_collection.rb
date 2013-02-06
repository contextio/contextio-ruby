require_relative 'api/resource_collection'
require_relative 'source'

class ContextIO
  class SourceCollection
    include ContextIO::API::ResourceCollection

    self.resource_class = ContextIO::Source
    self.association_name = :sources

    belongs_to :account

    # Creates a new source for an account.
    #
    # @param [String] email The email address for the new source.
    # @param [String] server The address of the server for the source.
    # @param [String] username The name for logging into the server. Often the
    #   same as the email.
    # @param [Boolean] use_ssl Whether to use SSL for the new source.
    # @param [Numeric, String] port The port to connect on.
    # @param [String] type Currently, only 'IMAP' is supported.
    # @param [Hash{String, Symbol => String}] options Information you can
    #   provide at creation. Check out the Context.IO documentation for what's
    #   required and what's optional.
    def create(email, server, username, use_ssl, port, type, options={})
      api_args = options.merge(
        'email' => email,
        'server' => server,
        'username' => username,
        'use_ssl' => use_ssl ? '1' : '0',
        'port' => port.to_s,
        'type' => type
      )

      result_hash = api.request(:post, resource_url, api_args)

      result_hash.delete('success')

      resource_class.new(api, result_hash)
    end
  end
end
