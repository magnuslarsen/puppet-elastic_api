# @summary Creates a role_mapping resource
#
# @param $create_http_method The method to use against the API when creating resources
# @param $ensure             Whether to create or delete the resource
# @param $get_url_path       The URL path to GET the existing configuration
# @param $host               The host to connect to
# @param $include_keys       Keys (in the hash) that we want to compare from the API
# @param $is_kibana_endpoint If the endpoint is the Kibana API or not
# @param $password           The password to use against the API
# @param $update_http_method The method to use against the API when updating resources
# @param $url_path           The URL path to deploy the payload to
# @param $username           The username to use against the API
#
# @param $dn_path The DN path in AD
# @param $roles   The roles to map to the dn_path
# @param $is_user If the dn_path points to a user, or not
#
# @param $name (namevar) The name of the mapping
#
define elastic_api::user_mapping (
  Array   $roles,
  String  $dn_path,
  Boolean $is_user = false,

  Array                    $include_keys        = ['roles', 'rules', 'enabled'],
  Boolean                  $is_kibana_endpoint  = false,
  Enum['present','absent'] $ensure              = 'present',
  Enum['PUT','POST']       $create_http_method  = 'POST',
  Enum['PUT','POST']       $update_http_method  = 'POST',
  String                   $get_url_path        = "_security/role_mapping/${name}",
  String                   $host                = $elastic_api::elastic_host,
  String                   $password            = $elastic_api::password,
  String                   $url_path            = "_security/role_mapping/${name}",
  String                   $username            = $elastic_api::username,
) {

  if $ensure == 'present' {
    if $is_user {
      $rules = {
        'field' => {
          'dn' => $dn_path,
        },
      }
    }
    else {
      $rules = {
        'field' => {
          'groups' => $dn_path,
        },
      }
    }

    $payload = {
      'enabled' => true,
      'roles'   => $roles,
      'rules'   => $rules,
    }

    elastic_call_api { $name:
      ensure             => $ensure,
      get_url_path       => $get_url_path,
      host               => $host,
      create_http_method => $create_http_method,
      update_http_method => $update_http_method,
      is_kibana_endpoint => $is_kibana_endpoint,
      password           => $password,
      payload            => $payload,
      url_path           => $url_path,
      username           => $username,
      include_keys       => $include_keys,
    }
  }
  else { # if $ensure = absent
    elastic_call_api { $name:
      ensure             => $ensure,
      get_url_path       => $get_url_path,
      host               => $host,
      create_http_method => $create_http_method,
      update_http_method => $update_http_method,
      is_kibana_endpoint => $is_kibana_endpoint,
      password           => $password,
      url_path           => $url_path,
      username           => $username,
      include_keys       => $include_keys,
    }
  }
}
