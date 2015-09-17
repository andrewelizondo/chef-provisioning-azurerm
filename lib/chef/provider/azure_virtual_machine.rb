require 'chef/provisioning/azurerm/azure_provider'

class Chef
  class Provider
    class AzureVirtualMachine < Chef::Provisioning::AzureRM::AzureProvider
      provides :azure_virtual_machine

      def whyrun_supported?
        true
      end

      action :create do
        converge_by("create or update Virtual Machine #{new_resource.name}") do
          create_virtual_machine
        end
      end

      action :destroy do
        converge_by("destroy Virtual Machine #{new_resource.name}") do
          # destroy the VM if it exists
        end
      end
      
      def create_virtual_machine
        virtual_machine = Azure::ARM::Compute::Models::VirtualMachine.new
        virtual_machine.type = 'Microsoft.Compute/virtualMachines'
        virtual_machine.properties = create_virtual_machine_properties
        virtual_machine.location = new_resource.location
        Chef::Log.warn("#{virtual_machine.inspect}")
        begin
          result = compute_management_client.virtual_machines.create_or_update(new_resource.resource_group, new_resource.name, virtual_machine).value!
          Chef::Log.warn("result: #{result.body.inspect}")
        rescue MsRestAzure::AzureOperationError => operation_error  
          error = operation_error.body['error']  
          Chef::Log.error "ERROR creating Virtual Machine:  #{error}"  
          raise operation_error  
        end  
      end

      def create_virtual_machine_properties
        virtual_machine_properties = Azure::ARM::Compute::Models::VirtualMachineProperties.new
        virtual_machine_properties.os_profile = create_os_profile
        virtual_machine_properties.hardware_profile = create_hardware_profile
        virtual_machine_properties.storage_profile = create_storage_profile
        virtual_machine_properties.network_profile = create_network_profile
        virtual_machine_properties
      end

      def create_os_profile
        os_profile = Azure::ARM::Compute::Models::OSProfile.new
        # windows_config = Azure::ARM::Compute::Models::WindowsConfiguration.new
        # windows_config.provision_vmagent = true
        # windows_config.enable_automatic_updates = true
        os_profile.computer_name = new_resource.computer_name
        os_profile.admin_username = new_resource.admin_username
        os_profile.admin_password = new_resource.admin_password
        # os_profile.windows_configuration = windows_config
        os_profile.secrets = []
        Chef::Log.warn("#{os_profile.inspect}")
        os_profile
      end

      def create_hardware_profile
        hardware_profile = Azure::ARM::Compute::Models::HardwareProfile.new
        hardware_profile.vm_size = new_resource.vm_size
        Chef::Log.warn("#{hardware_profile.inspect}")
        hardware_profile
      end

      def create_storage_profile
        storage_profile = Azure::ARM::Compute::Models::StorageProfile.new

        publisher, offer, sku, version = new_resource.storage_profile[:image_reference].split(':', 4)
        image_reference = Azure::ARM::Compute::Models::ImageReference.new
        image_reference.publisher = publisher
        image_reference.offer = offer
        image_reference.sku = sku
        image_reference.version = version

        os_disk = Azure::ARM::Compute::Models::OSDisk.new
        os_disk.name = "#{new_resource.storage_profile[:storage_account_name]}-os"
        os_disk.caching = 'ReadWrite' #Azure::ARM::Compute::Models::CachingTypes.ReadWrite
        os_disk.create_option = 'fromImage'

        virtual_hard_disk =  Azure::ARM::Compute::Models::VirtualHardDisk.new
        virtual_hard_disk.uri = "https://#{new_resource.storage_profile[:storage_account_name]}.blob.core.windows.net/vhds/#{new_resource.storage_profile[:storage_account_name]}-os.vhd"
        os_disk.vhd = virtual_hard_disk

        storage_profile.image_reference = image_reference
        storage_profile.os_disk = os_disk

        Chef::Log.warn("#{storage_profile.inspect}")
        storage_profile
      end

      def create_network_profile
        network_profile = Azure::ARM::Compute::Models::NetworkProfile.new
        network_interface = Azure::ARM::Compute::Models::NetworkInterfaceReference.new
        network_interface_properties = Azure::ARM::Compute::Models::NetworkInterfaceReferenceProperties.new
        network_interface_properties.primary = true
        network_interface.properties = network_interface_properties
        network_profile.network_interfaces.push network_interface
        Chef::Log.warn("#{network_profile.inspect}")
        network_profile
      end
    end
  end
end
