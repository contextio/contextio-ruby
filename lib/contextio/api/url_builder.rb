require 'contextio/connect_token_collection'
require 'contextio/oauth_provider_collection'
require 'contextio/email_settings'
require 'contextio/account_collection'
require 'contextio/source_collection'
require 'contextio/folder_collection'
require 'contextio/message_collection'
require 'contextio/body_part_collection'
require 'contextio/thread_collection'
require 'contextio/webhook_collection'
require 'contextio/email_address_collection'
require 'contextio/contact_collection'
require 'contextio/file_collection'

class ContextIO
  class API
    class URLBuilder
      class Error < StandardError; end

      # Tells you the right URL for a resource to fetch attributes from.
      #
      # @param [ContextIO::Resource, ContextIO::ResourceCollection] resource The
      #   resource or resource collection.
      #
      # @return [String] The path for that resource in the API.
      def self.url_for(resource)
        if (builder = @registered_urls[resource.class])
          builder.call(resource)
        else
          raise Error, "URL could not be built for unregistered Class: #{resource.class}."
        end
      end

      # Register a block that calculates the URL for a given resource.
      #
      # @param [Class] resource_class The class of the resource you are
      #   registering.
      # @param [Block] block The code that will compute the url for the
      #   resource. This is actually a path. Start after the version number of
      #   the API in the URL. When a URL is being calculated for a specific
      #   resource, the resource instance will be yielded to the block.
      #
      # @example For Accounts
      #   register_url ContextIO::Account do |account|
      #     "accounts/#{account.id}"
      #   end
      def self.register_url(resource_class, &block)
        @registered_urls ||= {}
        @registered_urls[resource_class] = block
      end

      register_url ContextIO::ConnectToken do |connect_token|
        "connect_tokens/#{connect_token.token}"
      end

      register_url ContextIO::ConnectTokenCollection do |connect_tokens|
        if connect_tokens.account && connect_tokens.account.id
          "accounts/#{connect_tokens.account.id}/connect_tokens"
        else
          'connect_tokens'
        end
      end

      register_url ContextIO::OAuthProvider do |oauth_provider|
        "oauth_providers/#{oauth_provider.provider_consumer_key}"
      end

      register_url ContextIO::OAuthProviderCollection do
        'oauth_providers'
      end

      register_url ContextIO::EmailSettings do
        'discovery'
      end

      register_url ContextIO::Account do |account|
        "accounts/#{account.id}"
      end

      register_url ContextIO::AccountCollection do
        'accounts'
      end

      register_url ContextIO::Source do |source|
        "accounts/#{source.account.id}/sources/#{source.label}"
      end

      register_url ContextIO::SourceCollection do |sources|
        "accounts/#{sources.account.id}/sources"
      end

      register_url ContextIO::FolderCollection do |folders|
        "accounts/#{folders.source.account.id}/sources/#{folders.source.label}/folders"
      end

      register_url ContextIO::Message do |message|
        "accounts/#{message.account.id}/messages/#{message.message_id}"
      end

      register_url ContextIO::MessageCollection do |messages|
        "accounts/#{messages.account.id}/messages"
      end

      register_url ContextIO::BodyPartCollection do |parts|
        "accounts/#{parts.message.account.id}/messages/#{parts.message.message_id}/body"
      end

      register_url ContextIO::Thread do |thread|
        "accounts/#{thread.account.id}/threads/#{thread.gmail_thread_id}"
      end

      register_url ContextIO::ThreadCollection do |threads|
        "accounts/#{threads.account.id}/threads"
      end

      register_url ContextIO::Webhook do |webhook|
        "accounts/#{webhook.account.id}/webhooks/#{webhook.webhook_id}"
      end

      register_url ContextIO::WebhookCollection do |webhooks|
        "accounts/#{webhooks.account.id}/webhooks"
      end

      register_url ContextIO::EmailAddress do |email_address|
        "accounts/#{email_address.account.id}/email_addresses/#{email_address.email}"
      end

      register_url ContextIO::EmailAddressCollection do |email_addresses|
        "accounts/#{email_addresses.account.id}/email_addresses"
      end

      register_url ContextIO::Contact do |contact|
        "accounts/#{contact.account.id}/contacts/#{contact.email}"
      end

      register_url ContextIO::ContactCollection do |contacts|
        "accounts/#{contacts.account.id}/contacts"
      end

      register_url ContextIO::File do |file|
        "accounts/#{file.account.id}/files/#{file.file_id}"
      end

      register_url ContextIO::FileCollection do |files|
        "accounts/#{files.account.id}/files"
      end
    end
  end
end
