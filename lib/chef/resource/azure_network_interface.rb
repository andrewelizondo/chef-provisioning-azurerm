require 'chef/provisioning/azurerm/azure_resource'

class Chef
  class Resource
    class AzureNetworkInterface < Chef::Provisioning::AzureRM::AzureResource
      resource_name :azure_network_interface
      actions :create, :destroy, :nothing
      default_action :create
      attribute :name, kind_of: String, name_attribute: true, regex: /^[\w\-\(\)\.]{0,80}$+(?<!\.)$/i
      attribute :location, kind_of: String, default: 'westus'
      attribute :tags, kind_of: Hash
      attribute :resource_group, kind_of: String
    end
  end
end
