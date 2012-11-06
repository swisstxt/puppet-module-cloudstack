# Configure a Cloudstack controller 
#
# The controller server makes the API calls to Cloudstack to create
# loadbalancing rules, portforwarding rules, etc.
#
# == Parameters ==
#
# [url]
# *Mandatory* The URL of the Cloudstack API
# [api_key]
# *Mandatory* The Cloudstack API Key
# [secret_key]
# *Mandatory* The Cloudstack Secret Key
#
class cloudstack::controller(
  $url,
  $api_key,
  $secret_key,
){

    file{'/tmp/cloudstack.yaml':
      content => "url:  '$url'\napi_key:  '$api_key'\nsecret_key:  '$secret_key'\n",
      owner => root, group => 0, mode => 0400;
    }

}
