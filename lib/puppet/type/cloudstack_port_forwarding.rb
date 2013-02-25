require 'ipaddr'

module Puppet
  newtype(:cloudstack_port_forwarding) do
    @doc = "Manages a port forwarding rule in CloudStack:

      cloudstack_port_forwarding{'rule_name':
        ensure => 'present',
        vip,
        protocol,
        privateport,
        publicport,
        virtual_machine,
        virtual_machine_id
      }"

    ensurable

    newparam(:name, :namevar => true) do
      desc "The name of the rule to manage"
      isnamevar
    end

    newparam(:vip) do
      desc "The virtual IP of the port forwarding rule"
      validate do |value|
        fail("Invalid source #{value}") unless (IPAddr.new(value) rescue false)
      end
    end

    newparam(:publicport) do
      desc "Public port"
      newvalues(/[0-9]{1,5}/)
    end

    newparam(:privateport) do
      desc "Private port"
      newvalues(/[0-9]{1,5}/)
    end
    
    newparam(:virtual_machine) do
      desc "Name of the virtual machine"
    end
    
    newparam(:virtual_machine_id) do
      desc "Cloudstack ID of the virtual machine"
    end

    newparam(:protocol) do
      desc "The protocol of the port forwarding rule"
      defaultto 'TCP'
      newvalues('TCP', 'UDP')
    end
  end # Type
end # Module
