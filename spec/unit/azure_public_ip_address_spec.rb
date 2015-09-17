require 'spec_helper'

describe Chef::Resource::AzurePublicIPAddress do
  let(:resource) { Chef::Resource::AzurePublicIPAddress }

  it 'instantiates correctly with name' do
    expect(resource.new('publicIP').name).to eq('publicIP')
  end

  # it 'defaults to :create action' do
  #   expect(resource.new('resource-group').action).to eq([:create])
  # end
  
end
