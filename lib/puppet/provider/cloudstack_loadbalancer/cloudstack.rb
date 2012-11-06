require File.join(File.dirname(__FILE__), '../../../util/cloudstack_client')
require 'yaml'

Puppet::Type.type(:cloudstack_loadbalancer).provide(:cloudstack) do

  desc "Provider for the Cloudstack load balancer."

	def self.instances
		api = CloudstackClient::ConnectionHelper.api
		projectname = CloudstackClient::ConnectionHelper.load_configuration['project']
		instances = []

		loadbalancer_rules = api.list_loadbalancer_rules(projectname)
    loadbalancer_rules.each do |rule|
			instances << new(
				:name => rule['name'],
				:privateport => rule['privateport'],
				:publicport => rule['publicport'], 
				:algorithm => rule['algorithm'],
				:publicipid => rule['publicipid'],
				:ensure => :present
			)
		end
	
		instances
	end

	def self.prefetch(resources)
    instances.each do |prov|
      if resource = resources[prov.name]
        resource.provider = prov
      end
    end
  end


  def create
		api = CloudstackClient::ConnectionHelper.api
		ip_address = api.get_public_ip_address(@resource[:vip])
    params = {
      'command' => 'createLoadBalancerRule',
      'privateport' => @resource[:privateport],
      'publicport' => @resource[:publicport],
      'algorithm' => @resource[:algorithm],
      'publicipid' => ip_address['id'],
      'name' => @resource[:name]
    }
    api.send_request(params)
    true
  end

  def destroy
		api = CloudstackClient::ConnectionHelper.api
		projectname = CloudstackClient::ConnectionHelper.load_configuration['project']
		loadbalancer_rules = api.list_loadbalancer_rules(projectname)

    rule = loadbalancer_rules.find {|rule| rule['name'] == @resource[:name] } || false
    if rule
      params = {
        'command' => 'deleteLoadBalancerRule',
        'id' => rule['id']
      }
      api.send_request(params)
    end
    true
  end

  def exists?
		get(:ensure) != :absent
  end

  
end
