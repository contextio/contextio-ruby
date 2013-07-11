require 'contextio/api/resource'

class ContextIO
  class Message
    include ContextIO::API::Resource

    self.primary_key = :message_id
    self.association_name = :message

    belongs_to :account
    has_many :sources
    has_many :body_parts

    lazy_attributes :date, :folders, :addresses, :subject, :list_help,
                    :list_unsubscribe, :message_id, :email_message_id,
                    :gmail_message_id, :gmail_thread_id, :person_info,
                    :date_received, :date_indexed, :in_reply_to
    private :date_received, :date_indexed

    def received_at
      @received_at ||= Time.at(date_received)
    end

    def indexed_at
      @indexed_at ||= Time.at(date_indexed)
    end

    def flags
      api.request(:get, "#{resource_url}/flags")
    end

    # As of this writing, the documented valid flags are: seen, answered,
    # flagged, deleted, and draft. However, this will send whatever you send it.
    def set_flags(flag_hash)
      args = flag_hash.map({}) do |memo, (flag_name, value)|
        memo[flag_name] = value ? 1 : 0
        memo
      end

      api.request(:post, resource_url, args)['success']
    end

    def folders
      api.request(:get, "#{resource_url}/folders").collect { |f| f['name'] }
    end

    def headers
      api.request(:get, "#{resource_url}/headers")
    end

    %w(from to bcc cc reply_to).each do |f|
      define_method(f) do
        addresses[f]
      end
    end

    def raw
      api.raw_request(:get, "#{resource_url}/source")
    end

    # You can call this with a Folder object, in which case, the source from the
    # folder will be used, or you can pass in a folder name and source label.
    def copy_to(folder, source = nil)
      if folder.is_a?(ContextIO::Folder)
        folder_name = folder.name
        source_label = folder.source.label
      else
        folder_name = folder.to_s
        source_label = source.to_s
      end

      api.request(:post, resource_url, dst_folder: folder_name, dst_source: source_label)['success']
    end

    # You can call this with a Folder object, in which case, the source from the
    # folder will be used, or you can pass in a folder name and source label.
    def move_to(folder, source = nil)
      if folder.is_a?(ContextIO::Folder)
        folder_name = folder.name
        source_label = folder.source.label
      else
        folder_name = folder.to_s
        source_label = source.to_s
      end

      api.request(:post, resource_url, dst_folder: folder_name, dst_source: source_label, move: 1)['success']
    end

    def delete
      api.request(:delete, resource_url)['success']
    end

    private

    # The API doesn't return enough information to build a resource_url for this
    # resource, or the resource_url its self, making this problematic. Marking
    # this private until something is sorted on that front.
    def thread
      ContextIO::Thread.new(api, api.request(:get, "#{resource_url}/thread").merge(account: account))
    end
  end
end
