require File.join(File.dirname(__FILE__), '../../../util/cloudstack_client')

Puppet::Type.type(:cloudstack_loadbalancer_node).provide(:cloudstack) do
  include CloudstackClient::Helper

  desc "Provider for the Cloudstack load balancer."
  
  def self.instances
    extend CloudstackClient::Helper

    instances = []
    
    params = {
      'command' => 'listLoadBalancerRules',
    }
    params['projectid'] = project['id'] if project
    json = api.send_request(params)
   
    if json.has_key?('loadbalancerrule') 
      json['loadbalancerrule'].each do |rule|
        params = {
          'command' => 'listLoadBalancerRuleInstances',
          'id' => rule['id'],
          'listall' => true,
        }
        params['projectid'] = project['id'] if project
        json = api.send_request(params)
        members = json['loadbalancerruleinstance'] || []
        members.each do |member|
          instances << new(:name => "#{rule['name']}_#{member['name']}", :hostname => member['name'], :ensure => :present)
        end
      end
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
      'command' => 'assignToLoadBalancerRule',
      'id' => rule['id'],
      'virtualmachineids' => [server['id']]
    }
    api.send_request(params)
    true
  end

  def destroy
    params = {
      'command' => 'removeFromLoadBalancerRule',
      'id' => rule['id'],
      'virtualmachineids' => [server['id']]
    }
    api.send_request(params)
    true
  end

  def exists?
  	get(:ensure) != :absent
  end
  
  private
  
  def server
		params = {
    	'command' => 'listVirtualMachines',
      'name' => @resource[:hostname],
      'zoneid' => rule['zoneid']
    }
    params['projectid'] = project['id'] if project
    json = api.send_request(params)
    machines = json['virtualmachine'] || []
		machines.find { |machine| machine['name'] == @resource[:hostname] }
  end
  
  def rule_instances
    params = {
      'command' => 'listLoadBalancerRuleInstances',
      'id' => rule['id'],
      'listall' => true
    }
    params['projectid'] = project['id'] if project
    json = api.send_request(params)
    json['loadbalancerruleinstance'] || []
  end
  
  def rule
    params = {
      'command' => 'listLoadBalancerRules'
    }
    params['projectid'] = project['id'] if project
    json = api.send_request(params)
    loadbalancer_rules = json['loadbalancerrule'] || []
    loadbalancer_rules.find { |rule| rule['name'] == @resource[:service] }
  end
end
