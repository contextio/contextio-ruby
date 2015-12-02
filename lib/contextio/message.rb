require 'contextio/api/resource'

class ContextIO
  class Message
    include ContextIO::API::Resource

    self.primary_key = :message_id
    self.association_name = :message

    belongs_to :account
    has_many :sources
    has_many :body_parts
    has_many :files

    lazy_attributes :date, :folders, :addresses, :subject, :list_help,
                    :list_unsubscribe, :message_id, :email_message_id,
                    :gmail_message_id, :gmail_thread_id, :person_info,
                    :date_received, :date_indexed, :in_reply_to, :references

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
      args = flag_hash.inject({}) do |memo, (flag_name, value)|
        memo[flag_name] = value ? 1 : 0
        memo
      end

      api.request(:post, "#{resource_url}/flags", args)['success']
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

    # You can call this with a Folder object or the Folder name.
    def remove_from(folder)
      if folder.is_a?(ContextIO::Folder)
        folder_name = folder.name
      else
        folder_name = folder.to_s
      end
      api.request(:post, resource_url+"/folders", remove:folder_name)['success']
    end

    def delete
      api.request(:delete, resource_url)['success']
    end

    # Returns a list of all messages and a list of all email_message_ids in the same thread as this message.
    # Note that it does not create a Thread object or a MessageCollection object in its current state.
    def thread
      api.request(:get, "#{resource_url}/thread")
    end
  end
end
