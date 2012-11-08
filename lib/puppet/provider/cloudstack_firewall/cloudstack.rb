require File.join(File.dirname(__FILE__), '../../../util/cloudstack_client')

Puppet::Type.type(:cloudstack_firewall).provide(:cloudstack) do
  
  include CloudstackClient::Helper

  desc "Provider for the CloudStack firewall."

	def self.instances
    extend CloudstackClient::Helper
    
    instances = []
    params = {
      'command' => 'listFirewallRules',
      'projectid' => project['id']
    }
    json = api.send_request(params)
    json['firewallrule'].each do |fw_rule|
      instances << new(
        :vip => fw_rule['ipaddress'],
        :startport => fw_rule['startport'],
        :endport => fw_rule['endport'],
        :protocol => fw_rule['protocol'],
        :cidrlist => fw_rule['cidrlist'],
        :cidrlist => fw_rule['cidrlist'],
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
      'command' => 'createFirewallRule',
      'protocol' => @resource[:protocol],
      'startport' => @resource[:startport],
      'endport' => @resource[:endport],
      'cidrlist' => @resource[:cidrlist],
      'ipaddressid' => public_ip_address['id'],

    }
    api.send_request(params)
    true
  end

  def destroy
    vip = public_ip_address(@resource[:vip])
    
    params = {
      'command' => 'listFirewallRules',
      'projectid' => project['id'],
      'ipaddressid' => vip['id']
    }
    json = api.send_request(params)
    firewall_rules = json['firewallrule']
    
    rule = firewall_rules.find do |rule|
        rule['protocol'] == @resource[:protocol] &&
        rule['startport'] == @resource[:startport] &&
        rule['endport'] == @resource[:endport] &&
        rule['cidrlist'] == @resource[:cidrlist]
    end
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
  	get(:ensure) != :absent
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

end
