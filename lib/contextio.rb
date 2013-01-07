# Provides an object-oriented interface for the Context.IO API.
#
# To use it, you have to [sign up for an account](http://context.io).
#
# Once you have an account, you can create a new `ContextIO` object and interact
# with the API using the methods on that object as a starting point.
class ContextIO
  # @private
  # Handle for the `API` instance. For internal use only.
  attr_reader :api

  # Creates a new `ContextIO` instance and makes a new handle for the API.
  # This is your entry point to your Context.IO account.  For a web app, you
  # probably want to instantiate this in some kind of initializer and keep it
  # around for the life of the process.
  #
  # @param [String] key Your OAuth consumer key for your Context.IO account
  # @param [String] secret Your OAuth consumer secret for your Context.IO
  #   account
  # @param [Hash] opts Optional options for OAuth connections. ie. :timeout and :open_timeout are supported
  def initialize(key, secret, opts={})
    @api = API.new(key, secret, opts)
  end

  # Your entry point for dealing with oauth providers.
  #
  # @return [OAuthProviderCollection] Allows you to work with the providers for
  #   your account as a group.
  def oauth_providers
    OAuthProviderCollection.new(api)
  end

  # Your entry point for dealing with connect tokens.
  #
  # @return [ConnectTokenCollection] Allows you to work with the tokens for
  #   your account as a group.
  def connect_tokens
    ConnectTokenCollection.new(api)
  end

  # Your entry point for dealing with accounts.
  #
  # @return [AccountCollection] Allows you to work with the email accounts for
  #   your account as a group.
  def accounts
    AccountCollection.new(api)
  end

  # Discover the IMAP settings for an email account.
  #
  # @param [String] email_address The email address in question.
  # @param [String] source_type The only source type currently supported by the
  #   API is 'IMAP'.
  #
  # @return [EmailSettings] Allows you to inspec the settings for an account's
  #   IMAP server.
  def email_settings_for(email_address, source_type = 'IMAP')
    EmailSettings.new(api, email_address, source_type)
  end
end

require_relative 'contextio/version'

require_relative 'contextio/api'

require_relative 'contextio/oauth_provider_collection'
require_relative 'contextio/email_settings'
require_relative 'contextio/connect_token_collection'
require_relative 'contextio/account_collection'
require_relative 'contextio/source_collection'
require_relative 'contextio/folder_collection'
require_relative 'contextio/message_collection'
require_relative 'contextio/body_part_collection'
require_relative 'contextio/thread_collection'
require_relative 'contextio/webhook_collection'
require_relative 'contextio/contact_collection'
