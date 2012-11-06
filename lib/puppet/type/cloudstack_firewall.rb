module Puppet
  newtype(:cloudstack_firewall) do
    @doc = "Manages a firewall rule in CloudStack::

      cloudstack_firewall{'ssh':
        ensure => 'present',
        vip,
        protocol,
        startport,
        endport,
        project => 'Playground',
        apiurl => 'http://mycloud.com/client/api',
        apikey => 'your-cloudstack-api-key',
        secretkey => 'your-cloudstack-secret-key'
      }"

    ensurable

    newparam(:name, :namevar => true) do
      desc "The rule to manage"
      isnamevar
    end

    newparam(:vip) do
      desc "The virtual IP of the firewall rule"
    end

    newparam(:protocol) do
      desc "The protocol of the firewall rule"
    end

    newparam(:startport) do
      desc "Start port"
    end

		newparam(:endport) do
      desc "End port"
    end

    newparam(:cloudstack_url) do
      desc "URL of the loadbalancer API"
    end

    newparam(:cloudstack_api_key) do
      desc "API Key for the loadbalancer"
    end

    newparam(:cloudstack_secret_key) do
      desc "Secret for the loadbalancer"
    end
    
		newproperty(:cidrlist) do
			desc "Mask(s) of IPs permitted to the service"
			defaultto { "0.0.0.0/0" }
		end

		newproperty(:type) do
			desc "Rule type"
			defaultto { "user" }
		end

		newproperty(:icmptype) do
			desc "Type of permitted ICMP packets"
			defaultto { "-1" }
		end

		newproperty(:icmpcode) do
			desc "Code of permitted ICMP packets"
			defaultto { "-1" }
		end


  end
end

