require 'uri'
require 'oauth'
require 'json'

require 'contextio/api/url_builder'

class ContextIO
  # **For internal use only.** Users of this gem should not be using this
  # directly.  Represents the handle on the Context.IO API. It handles the
  # user's OAuth credentials with Context.IO and signing requests, etc.
  class API
    # For differentiating API errors from other errors that might happen during
    # requests.
    class Error < StandardError; end

    # @private
    VERSION = '2.0'

    # @return [String] The version of the Context.IO API this version of the
    #   gem is intended for use with.
    def self.version
      VERSION
    end

    # @private
    BASE_URL = 'https://api.context.io'

    # @return [String] The base URL the API is served from.
    def self.base_url
      BASE_URL
    end

    # @param [Object] resource The resource you want the URL for.
    #
    # @return [String] The URL for the resource in the API.
    def self.url_for(resource)
      ContextIO::API::URLBuilder.url_for(resource)
    end

    # @param [Object] resource The resource you want the URL for.
    #
    # @return [String] The URL for the resource in the API.
    def url_for(resource)
      ContextIO::API.url_for(resource)
    end

    def self.user_agent_string
      "contextio-ruby-#{ContextIO.version}"
    end

    def user_agent_string
      self.class.user_agent_string
    end

    # @!attribute [r] key
    #   @return [String] The OAuth key for the user's Context.IO account.
    # @!attribute [r] secret
    #   @return [String] The OAuth secret for the user's Context.IO account.
    # @!attribute [r] opts
    #   @return [Hash] opts Optional options for OAuth connections.
    attr_reader :key, :secret, :opts

    # @param [String] key The user's OAuth key for their Context.IO account.
    # @param [String] secret The user's OAuth secret for their Context.IO account.
    # @param [Hash] opts Optional options for OAuth connections. ie. :timeout and :open_timeout are supported
    def initialize(key, secret, opts={})
      @key = key
      @secret = secret
      @opts = opts || {}
    end

    # Generates the path for a resource_path and params hash for use with the API.
    #
    # @param [String] resource_path The resource_path or full resource URL for
    #   the resource being acted on.
    # @param [{String, Symbol => String, Symbol, Array<String, Symbol>}] params
    #   A Hash of the query parameters for the action represented by this path.
    def path(resource_path, params = {})
      "/#{API.version}/#{API.strip_resource_path(resource_path)}#{API.hash_to_url_params(params)}"
    end

    # Makes a request against the Context.IO API.
    #
    # @param [String, Symbol] method The HTTP verb for the request (lower case).
    # @param [String] resource_path The path to the resource in question.
    # @param [{String, Symbol => String, Symbol, Array<String, Symbol>}] params
    #   A Hash of the query parameters for the action represented by this
    #   request.
    #
    # @raise [API::Error] if the response code isn't in the 200 or 300 range.
    def request(method, resource_path, params = {})
      response = oauth_request(method, resource_path, params)
      body = response.body
      results = JSON.parse(body) unless response.body.empty?

      if response.code =~ /[45]\d\d/
        if results.is_a?(Hash) && results['type'] == 'error'
          message = results['value']
        else
          message = response.message
        end

        raise API::Error, message
      end

      results
    end

    def raw_request(method, resource_path, params={})
      response = oauth_request(method, resource_path, params, 'User-Agent' => user_agent_string)

      if response.code =~ /[45]\d\d/
        raise API::Error, response.message
      end

      response.body
    end

    private

    # Makes a request signed for OAuth, encoding parameters correctly, etc.
    #
    # @param [String, Symbol] method The HTTP verb for the request (lower case).
    # @param [String] resource_path The path to the resource in question.
    # @param [{String, Symbol => String, Symbol, Array<String, Symbol>}] params
    #   A Hash of the query parameters for the action represented by this
    #   request.
    #
    # @return [Net::HTTP*] The response object from the request.
    def oauth_request(method, resource_path, params, headers=nil)
      headers ||= { 'Accept' => 'application/json', 'User-Agent' => user_agent_string }

      # The below array used to include put, too, but there is a weirdness in
      # the oauth gem with PUT and signing requests. See
      # https://github.com/oauth/oauth-ruby/pull/34#issuecomment-5862199 for
      # some discussion on the matter. This is a work-around.
      if %w(post).include? method.to_s.downcase
        token.request(method, path(resource_path), params, headers)
      else # GET, DELETE, HEAD, etc.
        token.request(method, path(resource_path, params), nil, headers)
      end
    end

    # So that we can accept full URLs, this strips the domain and version number
    # out and returns just the resource path.
    #
    # @param [#to_s] resource_path The full URL or path for a resource.
    #
    # @return [String] The resource path.
    def self.strip_resource_path(resource_path)
      resource_path.to_s.gsub("#{base_url}/#{version}/", '')
    end

    # Context.IO's API expects query parameters that are arrays to be comma
    # separated, rather than submitted more than once. This munges those arrays
    # and then URL-encodes the whole thing into a query string.
    #
    # @param [{String, Symbol => String, Symbol, Array<String, Symbol>}] params
    #   A Hash of the query parameters.
    #
    # @return [String] A URL-encoded version of the query parameters.
    def self.hash_to_url_params(params = {})
      return '' if params.empty?

      params = params.inject({}) do |memo, (k, v)|
        memo[k] = Array(v).join(',')

        memo
      end

      "?#{URI.encode_www_form(params)}"
    end

    # @!attribute [r] consumer
    # @return [OAuth::Consumer] An Oauth consumer object for credentials
    #   purposes.
    def consumer
      @consumer ||= OAuth::Consumer.new(key, secret, @opts.merge(site: API.base_url))
    end

    # @!attribute [r] token
    # @return [Oauth::AccessToken] An Oauth token object for credentials
    #   purposes.
    def token
      @token ||= OAuth::AccessToken.new(consumer)
    end
  end
end
