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
# @param $display_name The display name for the space
# @param $color        The color of the avatar (HEX value)
# @param $description  The description of the space
# @param $initials     The initials in the avatar (1 or 2 characters)
#
# @param $name (namevar) The name of the space
#
define elastic_api::space (
  String $display_name,
  Variant[String,Undef] $color       = undef,
  Variant[String,Undef] $description = undef,
  Variant[String,Undef] $initials    = undef,

  Array                    $include_keys        = ['id', 'name', 'description', 'color', 'initials'],
  Boolean                  $is_kibana_endpoint  = true,
  Enum['present','absent'] $ensure              = 'present',
  Enum['PUT','POST']       $create_http_method  = 'POST',
  Enum['PUT','POST']       $update_http_method  = 'PUT',
  String                   $get_url_path        = "api/spaces/space/${name}",
  String                   $host                = $elastic_api::kibana_host,
  String                   $password            = $elastic_api::password,
  String                   $url_path            = 'api/spaces/space',
  String                   $username            = $elastic_api::username,
) {

  if $ensure == 'present' {
    if $color != undef and $initials != undef {
      $payload = {
        'id'          => $name,
        'name'        => $display_name,
        'description' => $description,
        'color'       => downcase($color),
        'initials'    => $initials,
      }
    }
    elsif $initials != undef {
      $payload = {
        'id'          => $name,
        'name'        => $display_name,
        'description' => $description,
        'initials'    => $initials,
      }
    }
    elsif $color != undef {
      $payload = {
        'id'          => $name,
        'name'        => $display_name,
        'description' => $description,
        'color'       => downcase($color),
      }
    }
    else {
      $payload = {
        'id'          => $name,
        'name'        => $display_name,
        'description' => $description,
      }
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
      url_path           => $get_url_path, # This has the ID in the path
      username           => $username,
      include_keys       => $include_keys,
    }
  }

}
