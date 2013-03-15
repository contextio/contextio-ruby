class ContextIO
  # Represents the IMAP settings for a given email address. The API
  # documentation refers to this as 'discovery'. This process is hit-and-miss.
  # If noting is found, many attributes are likely to be nil and blank. Check
  # {EmailSettings#found? EmailSettings#found?}.
  class EmailSettings
    # (see ContextIO#api)
    attr_reader :api

    # @!attribute [r] type
    # @return [String] The type og the provider (like 'gmail'). Will fetch from
    #   the API if necessary.
    def type
      return @type if instance_variable_defined?(:@type)

      fetch_attributes

      @type
    end

    # @!attribute [r] documentation
    # @return [Array<String>] A list of documentation pages that pertain to the
    #   provider. Will fetch from the API if necessary.
    def documentation
      return @documentation if instance_variable_defined?(:@documentation)

      fetch_attributes

      @documentation
    end

    # @!attribute [r] email
    # @return [String] The email address associated with these IMAP settings.
    attr_reader :email, :source_type

    # Not sure why, but the below comment has to be below the attr_reader call
    # above.

    # @!attribute [r] source_type
    # @return [String] The only source type currently supported by the API is
    #   'IMAP'.

    # (see ContextIO::OAuthProviderCollection#initialize)
    # @param [String] email The email address to fetch the settings for.
    # @param [String] source_type The only source type currently supported by
    #   the API is 'IMAP'.
    def initialize(api, email, source_type = 'IMAP')
      @api = api
      @email = email
      @source_type = source_type
    end

    # @!attribute [r] resource_url
    # @return [String] The path for discovering email settings.
    def resource_url
      'discovery'
    end

    # @!attribute [r] found?
    # @return [Boolean] Whether the settings were able to be fetched. Will fetch
    #   from the API if necessary.
    def found?
      found
    end

    # @!attribute [r] server
    # @return [String] FQDN of the IMAP server. Will fetch from the API if
    #   necessary.
    def server
      imap['server']
    end

    # @!attribute [r] username
    # @return [String] The username for authentication purposes. Will fetch
    #   from the API if necessary.
    def username
      imap['username']
    end

    # @!attribute [r] port
    # @return [Integer] The network port the IMAP server is listening on. Will
    #   fetch from the API if necessary.
    def port
      imap['port']
    end

    # @!attribute [r] oauth?
    # @return [Boolean] Whether the IMAP server supports OAuth or not. Will
    #   fetch from the API if necessary.
    def oauth?
      !!imap['oauth']
    end

    # @!attribute [r] use_ssl?
    # @return [Boolean] Whether the IMAP server uses SSL for connections. Will
    #   fetch from the API if necessary.
    def use_ssl?
      !!imap['use_ssl']
    end

    private

    # @!attribute [r] imap
    # @return [Hash{String => String, Boolean, Integer}] Attributes of the IMAP
    #   server in question.
    def imap
      return @imap if instance_variable_defined?(:@imap)

      fetch_attributes

      @imap
    end

    # @!attribute [r] found
    # @return [Boolean] Whether the settings were able to be fetched. Will fetch
    #   from the API if necessary.
    def found
      return @found if instance_variable_defined?(:@found)

      fetch_attributes

      @found
    end

    # Fetches attributes from the API for the email settings.
    #
    # Defines getter methods for any attributes that come back and don't
    # already have them. This way, if the API expands, the gem will still let
    # users get attributes we didn't explicitly declare as lazy.
    def fetch_attributes
      attr_hashes = api.request(:get, resource_url, 'email' => email, 'source_type' => source_type)

      attr_hashes.each do |key, value|
        key = key.to_s.gsub('-', '_')

        instance_variable_set("@#{key}", value)

        unless respond_to?(key)
          instance_eval <<-RUBY
            def #{key}
              @#{key}
            end
          RUBY
        end
      end
    end
  end
end
