module Puppet
	newtype(:cloudstack_loadbalancer) do

		@doc = "Manages a Service entry on the Loadbalancer::

		load { \"www.example.com\":
			ensure => present,
			vip => \"192.168.0.1\",
		}"

		ensurable

		newparam(:name, :namevar => true) do
			desc "The record to manage"
			isnamevar
		end

		newparam(:vip) do
			desc "..."
    end

		newparam(:algorithm) do
			desc "load balancer algorithm (source, roundrobin, leastconn)"
		end

		newparam(:privateport) do
			desc "..."
		end
		newparam(:publicport) do
			desc "..."
		end

		newparam(:projectname) do
			desc "..."
		end


		newparam(:cloudstack_url) do
			desc "Url of the loadbalancer API"
		end

		newparam(:cloudstack_api_key) do
			desc "API Key for the loadbalancer"
		end

		newparam(:cloudstack_secret_key) do
			desc "Secret for the loadbalancer"
		end

	end
end

