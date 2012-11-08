module Puppet
  newtype(:cloudstack_firewall) do
    @doc = "Manages a firewall rules in CloudStack::

      cloudstack_firewall{'ssh':
        ensure => 'present',
        vip,
        protocol,
        startport,
        endport,
        cidrlist
      }"

    ensurable

    newparam(:name, :namevar => true) do
      desc "The rule to manage"
      isnamevar
    end

    newparam(:vip) do
      desc "The virtual IP of the firewall rule"
    end

    newparam(:startport) do
      desc "Start port"
    end

		newparam(:endport) do
      desc "End port"
    end
    
		newparam(:cidrlist) do
			desc "Mask(s) of IPs permitted to the service"
			defaultto { "0.0.0.0/0" }
		end

    newparam(:protocol) do
      desc "The protocol of the firewall rule"
			defaultto { "TCP" }
			validate do |val|
        fail("Invalid protocol #{val}") unless val == "TCP" || val == "UDP"
      end
    end
  end
end

