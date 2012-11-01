require File.join(File.dirname(__FILE__), '../../../util/cloudstack_client')

Puppet::Type.type(:cloudstack_loadbalancer).provide(:cloudstack) do

	desc "Provider for the cloudstack loadbalancer."

	def load_rules
		loadbalancer_rules = []

		cs = CloudstackClient::Connection.new(
        @resource[:cloudstack_url],
        @resource[:cloudstack_api_key],
        @resource[:cloudstack_secret_key]
    )

		projects = cs.list_projects

		projects.each do |project|
			params = {
        'command' => 'listLoadBalancerRules',
				'projectid' => project['id']
      }
      json = cs.send_request(params)
      loadbalancer_rules += json['loadbalancerrule']
		end
		return loadbalancer_rules
	end

	def create
		cs = CloudstackClient::Connection.new(
        @resource[:cloudstack_url],
        @resource[:cloudstack_api_key],
        @resource[:cloudstack_secret_key]
    )
		
		projectid = nil
		projects = cs.list_projects
		projects.each do |project|
			if project['name'] == @resource[:projectname]
				projectid = project['id']
			end
		end

		params = {
        'command' => 'listPublicIpAddresses',
        'ipaddress' => @resource[:vip],
				'projectid' => projectid
    }

		json = cs.send_request(params)
		puts json.inspect

		publicaddressid = json['publicipaddress'][0]['id']
		puts publicaddressid

		params = {
        'command' => 'createLoadBalancerRule',
				'privateport' => @resource[:privateport],
				'publicport' => @resource[:publicport],
				'algorithm' => @resource[:algorithm],
        'publicipid' => publicaddressid,
				'name' => @resource[:name]
      }
      json = cs.send_request(params)
	end

	def destroy
		File.unlink("/tmp/#{@resource[:name]}")
	end

	def exists?
		loadbalancer_rules = load_rules
		loadbalancer_rules.each do |rule|
			return true if rule['name'] == @resource[:name]
		end
		return false
	end

end
