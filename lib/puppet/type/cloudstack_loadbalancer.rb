module Puppet
  newtype(:cloudstack_loadbalancer) do
    @doc = "Manages a Service entry on the Loadbalancer::

      cloudstack_loadbalancer{'www.example.com':
        ensure => 'present',
        algorithm => 'roundrobin',
        privateport => '80',
        publicport => '80',
        vip => '192.168.1.1',
        projectname => 'Playground',
        cloudstack_url => 'http://mycloud.com/client/api',
        cloudstack_api_key => 'your-cloudstack-api-key',
        cloudstack_secret_key => 'your-cloudstack-api-secret',
      }"

    ensurable

    newparam(:name, :namevar => true) do
      desc "The record to manage"
      isnamevar
    end

    newparam(:vip) do
      desc "The virtual IP of the load balancer service"
    end

    newparam(:algorithm) do
      desc "load balancer algorithm (source, roundrobin, leastconn)"
    end

    newparam(:privateport) do
      desc "Private load balancer port"
    end

    newparam(:publicport) do
      desc "Public load balancer port"
    end

    newparam(:projectname) do
      desc "Name of the Cloudstack project"
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

