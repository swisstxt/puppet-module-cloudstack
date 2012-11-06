module Puppet
  newtype(:cloudstack_loadbalancer_node) do
    @doc = "Manages a node entry to a existing loadbalancer config::

      cloudstack_loadbalancer_node{'www.example.com':
        ensure => 'present',
        projectname => 'Playground',
        hostname => $::hostname
        cloudstack_url => 'http://mycloud.com/client/api',
        cloudstack_api_key => 'your-cloudstack-api-key',
        cloudstack_secret_key => 'your-cloudstack-api-secret',
      }"

    ensurable

    newparam(:name, :namevar => true) do
      desc "The record to manage"
      isnamevar
    end

    newparam(:hostname) do
      desc "Name of the host"
    end

    newparam(:projectname) do
      desc "Name of the Cloudstack project"
    end
  end
end

