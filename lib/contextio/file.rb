require 'contextio/api/resource'
require 'contextio/source_sync_data'

class ContextIO
  class File
    include ContextIO::API::Resource

    self.primary_key = :file_id
    self.association_name = :file

    belongs_to :account

    lazy_attributes :size, :type, :subject, :date, :addresses, :personInfo,
                    :email_message_id, :message_id, :date_indexed,
                    :date_received, :file_name, :file_name_structure,
                    :body_section, :content_disposition, :file_id,
                    :is_tnef_part, :gmail_message_id, :gmail_thread_id,
                    :supports_preview, :is_embedded
    private :date, :addresses, :message_id, :date_indexed, :date_received,
            :is_tnef_part, :is_embedded, :personInfo

    def received_at
      @received_at ||= Time.at(date_received)
    end

    def indexed_at
      @indexed_at ||= Time.at(indexed_at)
    end

    def to
      addresses['to']
    end

    def from
      addresses['from']
    end

    def person_info
      personInfo
    end

    def tnef_part?
      !!is_tnef_part
    end

    def embedded?
      !!is_embedded
    end

    def content
      @content ||= api.raw_request(:get, "#{resource_url}/content")
    end

    def content_link
      @content_link ||= api.raw_request(:get, "#{resource_url}/content", as_link: 1)
    end

    def related_files
      return @related_files if @related_files

      attribute_hashes = api.request(:get, "#{resource_url}/related")

      @related_files = FileCollection.new(api, attribute_hashes: attribute_hashes, account: account)

      return @related_files
    end

    def revisions
      return @revisions if @revisions

      attribute_hashes = api.request(:get, "#{resource_url}/revisions")

      @revisions = FileCollection.new(api, attribute_hashes: attribute_hashes, account: account)

      return @revisions
    end

  end
end
