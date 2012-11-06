require File.join(File.dirname(__FILE__), '../../../util/cloudstack_client')

Puppet::Type.type(:cloudstack_loadbalancer_node).provide(:cloudstack) do

  desc "Provider for the Cloudstack load balancer."
  
  def self.instances
    instances = []
    params = {
      'command' => 'listProjects',
      'listall' => true,
      'name' => CloudstackClient::ConnectionHelper.load_configuration[:project]
    }
    json = api.send_request(params)
    project = json['project'].first 
    
    params = {
      'command' => 'listLoadBalancerRules',
      'projectid' => project['id']
    }
    json = api.send_request(params)
    loadbalancer_rules = json['loadbalancerrule']
    loadbalancer_rules.each do |rule|
      params = {
        'command' => 'listLoadBalancerRuleInstances',
        'id' => rule['id'],
        'listall' => true,
        'projectid' => project['id']
      }
      json = api.send_request(params)
      instances = json['loadbalancerruleinstance'] || []
      instances.each do |instance|
        instances << new(
          :name => rule['name'],
          :hostname => instance['name'],
          :projectname => CloudstackClient::ConnectionHelper.load_configuration[:project]
        ) 
      end
    end
    instances   
  end

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
  
  private
  
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
    config = CloudstackClient::ConnectionHelper.load_configuration
    CloudstackClient::Connection.new(config)
  end
end
