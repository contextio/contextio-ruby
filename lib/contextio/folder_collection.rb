require_relative 'api/resource_collection'
require_relative 'folder'

class ContextIO
  class FolderCollection
    include ContextIO::API::ResourceCollection

    self.resource_class = ContextIO::Folder
    self.association_name = :folders

    belongs_to :source

    def create(folder_name, folder_delimiter='/')
      # Original 
      # => api.request(:put, "#{resource_url}/#{folder_name}", delim: folder_delimiter)['success']

      # Solution? 
      # => api.request(:put, "#{resource_url}/#{folder_name}?delim=#{folder_delimiter}", delim: folder_delimiter)['success']

      # Hotfix - 
      # => UNCOMMENTED BELOW

      # => Explanation START:
      # => Currently the folder delimiter parameter causes an error, took the parameter out and this
      # => method works now but this method cannot utilize the folder delimiter parameter functionality.
      # => END

      api.request(:put, "#{resource_url}/#{folder_name}")['success']
    end

  end
end

