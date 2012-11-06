require File.join(File.dirname(__FILE__), '../../../util/cloudstack_client')
require 'yaml'

Puppet::Type.type(:cloudstack_firewall).provide(:cloudstack) do

  desc "Provider for the CloudStack firewall."

	def self.instances
		config = CloudstackClient::ConnectionHelper.load_configuration
    api = CloudstackClient::Connection.new(
			config['url'],
			config['api_key'],
			config['secret_key']
		)

    projects = api.list_projects
    project = projects.find do |project| 
		end

	end

  def create
    params = {
      'command' => 'createFirewallRule',
      'protocol' => @resource[:protocol],
      'startport' => @resource[:startport],
      'endport' => @resource[:endport],
      'cidrlist' => @resource[:cidrlist],
      'ipaddressid' => public_ip_address['id'],
      'name' => @resource[:name]
    }
    api.send_request(params)
    true
  end

  def destroy
    rule = firewall_rules.find {|rule| rule['name'] == @resource[:name] } || false
    if rule
      params = {
        'command' => 'deleteFirewallRule',
        'id' => rule['id']
      }
      api.send_request(params)
    end
    true
  end

  def exists?
    firewall_rules.each do |rule|
      return true if rule['name'] == @resource[:name]
    end
    return false
  end

  private
  
  def public_ip_address
    params = {
      'command' => 'listPublicIpAddresses',
      'ipaddress' => @resource[:vip],
      'projectid' => project['id']
    }
    json = api.send_request(params)
    json['publicipaddress'].first
  end
  
  def self.project
    projects = api.list_projects
    projects.find {|project| project['name'] == CloudstackClient::ConnectionHelper.load_configuration[:project] }
  end
  
  def self.firewall_rules    
    params = {
      'command' => 'listFirewallRules'
    }
    json = api.send_request(params)
    json['listfirewallrule']
  end

  def self.api
		config = CloudstackClient::ConnectionHelper.load_configuration
    api = CloudstackClient::Connection.new(
			config['url'],
			config['api_key'],
			config['secret_key']
		)
  end
end
