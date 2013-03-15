require 'contextio/api/association_helpers'

class ContextIO
  class BodyPart
    def self.association_name
      :body_part
    end
    ContextIO::API::AssociationHelpers.register_resource(self, :body_part)

    # (see ContextIO#api)
    attr_reader :api, :message, :type, :charset, :delsp, :format, :content,
                :body_section

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
      @message = options.delete(:message) || options.delete('message')

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

    def html?
      type == 'text/html'
    end

    def plain_text?
      type == 'text/plain'
    end
  end
end
