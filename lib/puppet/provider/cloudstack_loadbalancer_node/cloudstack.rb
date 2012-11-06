require File.join(File.dirname(__FILE__), '../../../util/cloudstack_client')

Puppet::Type.type(:cloudstack_loadbalancer_node).provide(:cloudstack) do

  desc "Provider for the Cloudstack load balancer."
  
  def self.instances
		config = CloudstackClient::ConnectionHelper.load_configuration
    api = CloudstackClient::Connection.new(config['url'], config['api_key'], config['secret_key'])

    instances = []
    params = {
      'command' => 'listProjects',
      'listall' => true,
      'name' => config['project']
    }
    json = api.send_request(params)
    json.inspect
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
      members = json['loadbalancerruleinstance'] || []
      members.each do |member|
        instances << new(:name => rule['name'], :hostname => member['name'], :ensure => :present)
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
  	get(:ensure) != :absent
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
    loadbalancer_rules.find { |rule| rule['name'] == @resource[:service] }
  end
  
  def project
    project_name = CloudstackClient::ConnectionHelper.load_configuration['project'] 
		api.get_project(project_name)
  end

  def api
    config = CloudstackClient::ConnectionHelper.load_configuration
    CloudstackClient::Connection.new(config['url'], config['api_key'], config['secret_key'])
  end
end
