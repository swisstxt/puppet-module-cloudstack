require File.join(File.dirname(__FILE__), '../../../util/cloudstack_client')

Puppet::Type.type(:cloudstack_loadbalancer).provide(:cloudstack) do

  desc "Provider for the Cloudstack load balancer."

  def load_rules
    loadbalancer_rules = []
    projects = api.list_projects

    projects.each do |project|
      params = {
        'command' => 'listLoadBalancerRules',
        'projectid' => project['id']
      }
      json = api.send_request(params)
      loadbalancer_rules += json['loadbalancerrule']
    end
    return loadbalancer_rules
  end

  def create
    project_id = nil
    projects = api.list_projects
    project = projects.find {|project| project['name'] == @resource[:projectname] }

    params = {
      'command' => 'listPublicIpAddresses',
      'ipaddress' => @resource[:vip],
      'projectid' => project['id']
    }

    json = api.send_request(params)
    publicaddressid = json['publicipaddress'].first['id']

    params = {
      'command' => 'createLoadBalancerRule',
      'privateport' => @resource[:privateport],
      'publicport' => @resource[:publicport],
      'algorithm' => @resource[:algorithm],
      'publicipid' => publicaddressid,
      'name' => @resource[:name]
    }
    api.send_request(params)
    true
  end

  def destroy
    loadbalancer_rules = load_rules
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
    loadbalancer_rules = load_rules
    loadbalancer_rules.each do |rule|
      return true if rule['name'] == @resource[:name]
    end
    return false
  end

  private

  def api
    api = CloudstackClient::Connection.new(
      @resource[:cloudstack_url],
      @resource[:cloudstack_api_key],
      @resource[:cloudstack_secret_key]
    )
  end
end