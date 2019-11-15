# *!*!*! WARNING: THIS AN INTERNAL API BEING MANIPULATED TO DO WHAT WE WANT *!*!*!
#        There is NO guarantee whether the settings and the value are correct OR if the space exists!
#        Be careful, and check your settings before applying

# @summary Updates advanced settings
#
# @param $http_method The method to use against the API when creating resources
# @param $ensure      Whether to create or delete the resource
# @param $host        The host to connect to
# @param $password    The password to use against the API
# @param $url_path    The URL path to deploy the payload to
# @param $username    The username to use against the API
#
# @param $value   The value of the setting
# @param $space   The space to set the setting on
#
# @param $name (namevar) The name of the setting
#
define elastic_api::advanced_setting (
  NotUndef[Any] $value,
  String        $space,

  Enum['present','absent'] $ensure      = 'present',
  Enum['PUT','POST']       $http_method = 'POST',
  String                   $host        = $elastic_api::kibana_host,
  String                   $password    = $elastic_api::password,
  String                   $username    = $elastic_api::username,
) {
  if $ensure == 'present' {
    $payload = {
      'changes' => {
        $name => $value,
      },
    }

    elastic_call_settings_api { $name:
      ensure      => $ensure,
      host        => $host,
      http_method => $http_method,
      password    => $password,
      username    => $username,
      url_path    => "s/${space}/api/kibana/settings",
      setting     => $name,
      payload     => $payload,
    }
  }
  else {
    elastic_call_settings_api { $name:
      ensure      => $ensure,
      host        => $host,
      http_method => $http_method,
      password    => $password,
      username    => $username,
      url_path    => "s/${space}/api/kibana/settings",
      setting     => $name,
    }
  }
}
