require 'chef/provisioning/azurerm/azure_resource'

class Chef
  class Resource
    class AzureVirtualMachine < Chef::Provisioning::AzureRM::AzureResource
      resource_name :azure_virtual_machine
      actions :create, :destroy, :nothing
      default_action :create
      attribute :name, kind_of: String, name_attribute: true
      attribute :resource_group, kind_of: String
      attribute :location, kind_of: String, default: 'westus'
      attribute :tags, kind_of: Hash
      attribute :computer_name, kind_of: String, default: 'vm'
      attribute :admin_username, kind_of: String, default: 'azure'
      attribute :admin_password, kind_of: String, default: 'P2ssw0rd'
      attribute :vm_size, kind_of: String, default: 'Standard_D1'
      attribute :os_profile, kind_of: Hash
      attribute :storage_profile, kind_of: Hash
      attribute :network_profile, kind_of: Hash
      attribute :custom_data, kind_of: String
      attribute :os_type, kind_of: String, equal_to: %w(windows linux), default: 'windows'
      attribute :os_configuration, kind_of: Hash
    end
  end
end
