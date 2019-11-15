# @summary Creates a ILM policy resource
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
# @param $cold_enabled            If the Cold phase is active or not
# @param $cold_freeze_index       Whether to freeze indices or not in Cold phase
# @param $cold_min_age            Age before it can arrive in Cold phase
# @param $cold_number_of_replicas The numbers of replicas to use in Cold phase
# @param $cold_priority           Priority of indices in Cold phase
# @param $delete_min_age          Age before it can be deleted in Delete phase
# @param $hot_max_age             Age before it rotates to a new index, and arrives in Warm phase
# @param $hot_max_docs            Number of docs before it rotates to a new index, and arrives in Warm phase
# @param $hot_max_size            Size before it rotates to a new index, and arrives in Warm phase
# @param $hot_priority            Priority of indices in Hot phase
# @param $warm_enabled            If the Warm phase is active or not
# @param $warm_max_num_segments   The numbers of segments to use in Warm phase (force merge)
# @param $warm_number_of_replicas The numbers of replicas to use in Warm phase
# @param $warm_number_of_shards   The numbers of shards to use in Warm phase (shrink)
# @param $warm_priority           Priority of indices in Warm phase
#
# @param $name (namevar) The name of the policy
#
define elastic_api::ilm_policy (
  Array                    $include_keys        = ['policy'],
  Boolean                  $is_kibana_endpoint  = false,
  Enum['present','absent'] $ensure              = 'present',
  Enum['PUT','POST']       $create_http_method  = 'PUT',
  Enum['PUT','POST']       $update_http_method  = 'PUT',
  String                   $get_url_path        = "_ilm/policy/${name}",
  String                   $host                = $elastic_api::elastic_host,
  String                   $password            = $elastic_api::password,
  String                   $url_path            = "_ilm/policy/${name}",
  String                   $username            = $elastic_api::username,

  Boolean                $cold_enabled                  = true,
  Boolean                $cold_freeze_index             = false,
  Boolean                $warm_enabled                  = true,
  Integer                $cold_priority                 = 0,
  Integer                $hot_priority                  = 100,
  Integer                $warm_priority                 = 50,
  Variant[Integer,Undef] $cold_number_of_replicas       = undef,
  Variant[Integer,Undef] $warm_max_num_segments         = undef,
  Variant[Integer,Undef] $warm_number_of_replicas       = undef,
  Variant[Integer,Undef] $warm_number_of_shards         = undef,
  Variant[String,Undef]  $cold_min_age                  = '7d',
  Variant[String,Undef]  $delete_min_age                = '30d',
  Variant[String,Undef]  $hot_max_age                   = '7d',
  Variant[String,Undef]  $hot_max_docs                  = undef,
  Variant[String,Undef]  $hot_max_size                  = '50gb',
) {

  if $ensure == 'present' {
    # ILM is a very tricky API. It requires ONLY values that are an actual value (fair enough)
    # But Puppet requires every value to be set in the order it GETs from the API
    # ...so the next few hundred lines is to make both happy
    # (it made me unhappy)

    ## HOT PHASE ##
    if $hot_max_age != undef and $hot_max_size != undef and $hot_max_docs {
      $hot_phase_actions = {
        'rollover'     => {
          'max_size' => $hot_max_size,
          'max_age'  => $hot_max_age,
          'max_docs' => $hot_max_docs,
        },
        'set_priority' => {
          'priority' => $hot_priority,
        },
      }
    }
    elsif $hot_max_age != undef and $hot_max_size != undef {
      $hot_phase_actions = {
        'rollover'     => {
          'max_size' => $hot_max_size,
          'max_age'  => $hot_max_age,
        },
        'set_priority' => {
          'priority'   => $hot_priority,
        },
      }
    }
    elsif $hot_max_age != undef and $hot_max_docs != undef {
      $hot_phase_actions = {
        'rollover'     => {
          'max_age'  => $hot_max_age,
          'max_docs' => $hot_max_docs,
        },
        'set_priority' => {
          'priority' => $hot_priority,
        },
      }
    }
    elsif $hot_max_size != undef and $hot_max_docs != undef {
      $hot_phase_actions = {
        'rollover'     => {
          'max_size' => $hot_max_size,
          'max_docs' => $hot_max_docs,
        },
        'set_priority' => {
          'priority' => $hot_priority,
        },
      }
    }
    elsif $hot_max_size != undef {
      $hot_phase_actions = {
        'rollover'     => {
          'max_size' => $hot_max_size,
        },
        'set_priority' => {
          'priority' => $hot_priority,
        },
      }
    }
    elsif $hot_max_age != undef {
      $hot_phase_actions = {
        'rollover'     => {
          'max_age' => $hot_max_age,
        },
        'set_priority' => {
          'priority' => $hot_priority,
        },
      }
    }
    elsif $hot_max_docs != undef {
      $hot_phase_actions = {
        'rollover'     => {
          'max_docs' => $hot_max_docs,
        },
        'set_priority' => {
          'priority' => $hot_priority,
        },
      }
    }
    else {
      $hot_phase_actions = {
        'set_priority' => {
          'priority' => $hot_priority,
        },
      }
    }

    $hot_phase = {
      'min_age' => '0ms',
      'actions' => $hot_phase_actions,
    }


    ## WARM PHASE ##
    if $warm_enabled {
      if $warm_max_num_segments != undef and $warm_number_of_shards != undef and $warm_number_of_replicas != undef {
        $warm_phase_actions = {
          'allocate' => {
            'number_of_replicas' => $warm_number_of_replicas,
            'include' => { },
            'exclude' => { },
            'require' => { },
          },
          'forcemerge'   => {
            'max_num_segments' => $warm_max_num_segments,
          },
          'set_priority' => {
            'priority' => $warm_priority,
          },
          'shrink'       => {
            'number_of_shards' => $warm_number_of_shards,
          },
        }
      }
      elsif $warm_max_num_segments != undef and $warm_number_of_shards != undef {
        $warm_phase_actions = {
          'forcemerge'   => {
            'max_num_segments' => $warm_max_num_segments,
          },
          'set_priority' => {
            'priority' => $warm_priority,
          },
          'shrink'       => {
            'number_of_shards' => $warm_number_of_shards,
          },
        }
      }
      elsif $warm_number_of_shards != undef and $warm_number_of_replicas != undef {
        $warm_phase_actions = {
          'allocate' => {
            'number_of_replicas' => $warm_number_of_replicas,
            'include' => { },
            'exclude' => { },
            'require' => { },
          },
          'set_priority' => {
            'priority' => $warm_priority,
          },
          'shrink' => {
            'number_of_shards' => $warm_number_of_shards,
          },
        }
      }
      elsif $warm_max_num_segments != undef and $warm_number_of_replicas != undef {
        $warm_phase_actions = {
          'allocate' => {
            'number_of_replicas' => $warm_number_of_replicas,
            'include' => { },
            'exclude' => { },
            'require' => { },
          },
          'forcemerge' => {
            'max_num_segments' => $warm_max_num_segments,
          },
          'set_priority' => {
            'priority' => $warm_priority,
          },
        }
      }
      elsif $warm_number_of_replicas != undef {
        $warm_phase_actions = {
          'allocate' => {
            'number_of_replicas' => $warm_number_of_replicas,
            'include' => { },
            'exclude' => { },
            'require' => { },
          },
          'set_priority' => {
            'priority' => $warm_priority,
          },
        }
      }
      elsif $warm_max_num_segments != undef {
        $warm_phase_actions = {
          'forcemerge' => {
            'max_num_segments' => $warm_max_num_segments,
          },
          'set_priority' => {
            'priority' => $warm_priority,
          },
        }
      }
      elsif $warm_number_of_shards != undef {
        $warm_phase_actions = {
          'set_priority' => {
            'priority' => $warm_priority,
          },
          'shrink' => {
            'number_of_shards' => $warm_number_of_shards,
          },
        }
      }
      else {
        $warm_phase_actions = {
          'set_priority' => {
            'priority' => $warm_priority,
          },
        }
      }

      $warm_phase = {
        'min_age' => '0ms',
        'actions' => $warm_phase_actions,
      }
    }


    ## COLD PHASE ##
    if $cold_enabled {
      if $cold_freeze_index == true and $cold_number_of_replicas != undef {
        $cold_phase_actions = {
          'allocate' => {
            'number_of_replicas' => $cold_number_of_replicas,
            'include' => { },
            'exclude' => { },
            'require' => { },
          },
          'freeze' => { },
          'set_priority' => {
            'priority' => $cold_priority,
          },
        }
      }
      elsif $cold_freeze_index == true {
        $cold_phase_actions = {
          'freeze' => { },
          'set_priority' => {
            'priority' => $cold_priority,
          },
        }
      }
      elsif $cold_number_of_replicas != undef {
        $cold_phase_actions = {
          'allocate' => {
            'number_of_replicas' => $cold_number_of_replicas,
            'include' => { },
            'exclude' => { },
            'require' => { },
          },
          'set_priority' => {
            'priority' => $cold_priority,
          },
        }
      }
      else {
        $cold_phase_actions = {
          'set_priority' => {
            'priority' => $cold_priority,
          },
        }
      }

      $cold_phase = {
        'min_age' => $cold_min_age,
        'actions' => $cold_phase_actions,
      }
    }


    ## DELETE PHASE ##
    $delete_phase = {
      'min_age' => $delete_min_age,
      'actions' => {
        'delete' => {},
      },
    }


    ## CREATE PAYLOAD ##
    if $warm_enabled and $cold_enabled {
      $payload = {
        'policy' => {
          'phases' => {
            'warm'   => $warm_phase,
            'cold'   => $cold_phase,
            'hot'    => $hot_phase,
            'delete' => $delete_phase,
          },
        },
      }
    }
    elsif $warm_enabled {
      $payload = {
        'policy' => {
          'phases' => {
            'warm'   => $warm_phase,
            'hot'    => $hot_phase,
            'delete' => $delete_phase,
          },
        },
      }
    }
    elsif $cold_enabled {
      $payload = {
        'policy' => {
          'phases' => {
            'cold'   => $cold_phase,
            'hot'    => $hot_phase,
            'delete' => $delete_phase,
          },
        },
      }
    }
    else {
      $payload = {
        'policy' => {
          'phases' => {
            'hot'    => $hot_phase,
            'delete' => $delete_phase,
          },
        },
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
