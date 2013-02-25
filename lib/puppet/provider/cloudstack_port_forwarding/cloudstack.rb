require File.join(File.dirname(__FILE__), '../../../util/cloudstack_client')

Puppet::Type.type(:cloudstack_port_forwarding).provide(:cloudstack) do
  include CloudstackClient::Helper

  desc "Provider for the CloudStack port forwarding."

	def self.instances
    extend CloudstackClient::Helper
    
    instances = []
    params = {
      'command' => 'listPortForwardingRules',
      'listall' => 'true',
      'projectid' => project['id']
    }
    json = api.send_request(params)
    json['portforwardingrule'].each do |pf_rule|
      instances << new(
        :name => "#{pf_rule['ipaddress']}_#{pf_rule['privateport']}_#{pf_rule['publicport']}",
        :vip => pf_rule['ipaddress'],
        :privateport => pf_rule['privateport'],
        :publicport => pf_rule['publicport'],
        :protocol => pf_rule['protocol'],
        :virtual_machine => pf_rule['virtualmachinename'],
        :virtual_machine_id => pf_rule['virtualmachineid'],
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
      'command' => 'createPortForwardingRule',
      'protocol' => @resource[:protocol],
      'publicport' => @resource[:publicport],
      'privateport' => @resource[:privateport],
      'ipaddressid' => public_ip_address['id'],
      'virtualmachineid' => @resource[:virtual_machine_id],
      'openfirewall' => 'true',
    }
    api.send_request(params)
    true
  end

  def destroy
    vip = public_ip_address(@resource[:vip])
    
    params = {
      'command' => 'listPortForwardingRules',
      'projectid' => project['id'],
      'ipaddressid' => vip['id']
    }
    json = api.send_request(params)
    port_forwarding_rules = json['portforwardingrule']
    
    rule = port_forwarding_rules.find do |rule|
      rule['protocol'] == @resource[:protocol] &&
      rule['publicport'] == @resource[:publicport] &&
      rule['privateport'] == @resource[:privateport] &&
      rule['virtualmachineid'] == @resource[:virtual_machine_id]
    end
    if rule
      params = {
        'command' => 'deletePortForwardingRule',
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
