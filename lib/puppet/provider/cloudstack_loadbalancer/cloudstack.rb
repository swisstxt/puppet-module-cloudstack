require File.join(File.dirname(__FILE__), '../../../util/cloudstack_client')

Puppet::Type.type(:cloudstack_loadbalancer).provide(:cloudstack) do
  include CloudstackClient::Helper

  desc "Provider for the Cloudstack load balancer."

	def self.instances
    extend CloudstackClient::Helper
		instances = []
		api.list_loadbalancer_rules(config.project).each do |rule|
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
    params = {
      'command' => 'createLoadBalancerRule',
      'privateport' => @resource[:privateport],
      'publicport' => @resource[:publicport],
      'algorithm' => @resource[:algorithm],
      'publicipid' => public_ip_address['id'],
      'name' => @resource[:name]
    }
    api.send_request(params)
    true
  end

  def destroy
		rules = api.list_loadbalancer_rules(config.project)

    if loadbalancer_rules.find {|rule| rule['name'] == @resource[:name] }
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

  private

  def public_ip_address
    params = {
      'command' => 'listPublicIpAddresses',
      'ipaddress' => @resource[:vip]
    }
    params['projectid'] = project['id'] if project
    json = api.send_request(params)
    json['publicipaddress'].first
  end

end
