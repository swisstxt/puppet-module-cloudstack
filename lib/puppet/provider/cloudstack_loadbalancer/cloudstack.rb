require File.join(File.dirname(__FILE__), '../../../util/cloudstack_client')
require 'yaml'

Puppet::Type.type(:cloudstack_loadbalancer).provide(:cloudstack) do

  desc "Provider for the Cloudstack load balancer."

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
    loadbalancer_rules.each do |rule|
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
  
  def project
    projects = api.list_projects
    projects.find {|project| project['name'] == @resource[:projectname] }
  end
  
  def loadbalancer_rules    
    params = {
      'command' => 'listLoadBalancerRules',
      'projectid' => project['id']
    }
    json = api.send_request(params)
    json['loadbalancerrule']
  end

  def api
    api_config = YAML.load_file( '/etc/cloudstack.yaml' )
    api = CloudstackClient::Connection.new(
      api_config['url'],
      api_config['api_key'],
      api_config['secret_key']
    )
  end
end
