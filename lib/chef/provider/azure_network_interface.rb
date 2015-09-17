require 'chef/provisioning/azurerm/azure_provider'

class Chef
  class Provider
    class AzureNetworkInterface < Chef::Provisioning::AzureRM::AzureProvider
      provides :azure_network_interface

      def whyrun_supported?
        true
      end

      action :create do
        converge_by("create or update Network Interface #{new_resource.name}") do
          create_network_interface
        end
      end

      action :destroy do
        converge_by("destroy Network Interface #{new_resource.name}") do
          if network_interface_exists
            destroy_network_interface
          else
            action_handler.report_progress "Network Interface #{new_resource.name} was not found."
          end
        end
      end
      
      def network_interface_exists
        network_interface_list = network_management_client.network_interfaces.list(new_resource.resource_group).value!
        network_interface_list.body.value.each do |network_interface|
          return true if network_interface.name == new_resource.name
        end
        false
      end

      def create_network_interface
        network_interface = Azure::ARM::Network::Models::NetworkInterface.new
        network_interface.location = new_resource.location
        network_interface_properties = Azure::ARM::Network::Models::NetworkInterfacePropertiesFormat.new
        network_interface_properties.ip_configurations = # TODO - type Array<NetworkInterfaceIpConfiguration>
        network_interface_properties.dns_settings = #TODO - type NetworkInterfaceDnsSettings
        network_interface.properties = network_interface_properties
      
        begin
          result = network_management_client.network_interfaces.create_or_update(new_resource.resource_group, new_resource.name, public_ip_address).value!
          Chef::Log.debug(result)
        rescue MsRestAzure::AzureOperationError => operation_error
          error = operation_error.body['error']
          Chef::Log.error "#{error}"
          raise operation_error
        end
      end
      
      def destroy_network_interface
        begin
          result = network_management_client.network_interfaces.delete(new_resource.resource_group, new_resource.name).value!
          Chef::Log.debug(result)
        rescue MsRestAzure::AzureOperationError => operation_error
          error = operation_error.body['error']
          Chef::Log.error "#{error}"
          raise operation_error
        end
      end
    end
  end
end
