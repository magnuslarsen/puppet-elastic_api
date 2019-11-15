# @summary Creates a user_role resource
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
# @param $cluster          Cluster level permissions
# @param $indices          Indices level permissions
# @param $run_as           Run-as permissions
# @param $space_permission Space permissions
# @param $spaces           What spaces should be affected by $space_permission
#
# @param $name (namevar) The name of the role
#
define elastic_api::user_role (
  Array                     $cluster          = ['monitor'],
  Array                     $indices          = [{}],
  Array                     $run_as           = [],
  Array                     $spaces           = [],
  Enum['all','read','none'] $space_permission = 'none',

  Array                    $include_keys        = ['elasticsearch', 'kibana'],
  Boolean                  $is_kibana_endpoint  = true,
  Enum['present','absent'] $ensure              = 'present',
  Enum['PUT','POST']       $create_http_method  = 'PUT',
  Enum['PUT','POST']       $update_http_method  = 'PUT',
  String                   $get_url_path        = "api/security/role/${name}",
  String                   $host                = $elastic_api::kibana_host,
  String                   $password            = $elastic_api::password,
  String                   $url_path            = "api/security/role/${name}",
  String                   $username            = $elastic_api::username,
) {

  if $ensure == 'present' {

    # To enable setting 'none', the space_permission must be empty
    $_space_permission = $space_permission ? {
      'none'  => [],
      default => [$space_permission]
    }

    if $spaces == [] {
      $payload = {
        'elasticsearch' => {
          'cluster' => $cluster,
          'indices' => $indices,
          'run_as'  => $run_as,
        },
        'kibana' => [],
      }
    }
    else {
      $payload = {
        'elasticsearch' => {
          'cluster' => $cluster,
          'indices' => $indices,
          'run_as'  => $run_as,
        },
        'kibana' => [{
          'base'    => $_space_permission,
          'feature' => {},
          'spaces'  => $spaces,
        }],
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
      url_path           => $url_path,
      username           => $username,
      include_keys       => $include_keys,
    }
  }
}
