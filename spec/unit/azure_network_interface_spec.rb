require 'spec_helper'

describe Chef::Resource::AzureNetworkInterface do
  let(:resource) { Chef::Resource::AzureNetworkInterface }

  it 'instantiates correctly with name' do
    expect(resource.new('nic').name).to eq('nic')
  end

  # it 'defaults to :create action' do
  #   expect(resource.new('resource-group').action).to eq([:create])
  # end
  
end
