require 'spec_helper'

describe Chef::Resource::AzureVirtualMachine do
  let(:resource) { Chef::Resource::AzureVirtualMachine }

  it 'instantiates correctly with name' do
    expect(resource.new('vm').name).to eq('vm')
  end

  # it 'defaults to :create action' do
  #   expect(resource.new('resource-group').action).to eq([:create])
  # end

end
