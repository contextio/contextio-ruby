require 'contextio/api/association_helpers'

class ContextIO
  class Folder
    def self.association_name
      :folder
    end
    ContextIO::API::AssociationHelpers.register_resource(self, :folder)

    # (see ContextIO#api)
    attr_reader :api, :source, :name, :attributes, :delim, :nb_messages,
                :uidvalidity, :nb_unseen_messages
    private :attributes

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
      @source = options.delete(:source) || options.delete('source')

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

    def has_children?
      attributes['HasChildren']
    end

    def marked?
      attributes['Marked']
    end

    def imap_attributes
      attributes
    end

    def messages
      association_class = ContextIO::API::AssociationHelpers.class_for_association_name(:messages)

      @messages ||= association_class.new(api, account: source.account).where(folder: self.name)
    end
  end
end
