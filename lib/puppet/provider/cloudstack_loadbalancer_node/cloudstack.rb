require File.join(File.dirname(__FILE__), '../../../util/cloudstack_client')

Puppet::Type.type(:cloudstack_loadbalancer_node).provide(:cloudstack) do

  desc "Provider for the Cloudstack load balancer."

  def create
    params = {
      'command' => 'assignToLoadBalancerRule',
      'id' => rule['id'],
      'virtualmachineids' => [server['id']]
    }
    puts server['id']
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
    rule_instances.each do |instance|
      return true if instance['id'] == server['id']
    end
    return false
  end
  
  def server
		params = {
    	'command' => 'listVirtualMachines',
      'name' => @resource[:hostname],
			'projectid' => project['id'],
      'zoneid' => rule['zoneid']
    }
    json = api.send_request(params)
    machines = json['virtualmachine'] || []
		machines.find { |machine| machine['name'] == @resource[:hostname] }
  end
  
  def rule_instances
    params = {
      'command' => 'listLoadBalancerRuleInstances',
      'id' => rule['id'],
      'listall' => true,
      'projectid' => project['id']
    }
    json = api.send_request(params)
    json['loadbalancerruleinstance'] || []
  end
  
  def rule
    params = {
      'command' => 'listLoadBalancerRules',
      'projectid' => project['id']
    }
    json = api.send_request(params)
    loadbalancer_rules = json['loadbalancerrule']
    loadbalancer_rules.find { |rule| rule['name'] == @resource[:name] }
  end
  
  def project
    projects = api.list_projects
    projects.find {|project| project['name'] == @resource[:projectname] }
  end

  def api
    api = CloudstackClient::Connection.new(
      @resource[:cloudstack_url],
      @resource[:cloudstack_api_key],
      @resource[:cloudstack_secret_key]
    )
  end
end
