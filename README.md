# Overview
This module will manage Elastic Stack settings, using the Elasticsearch/Kibana API.

This module has been tested on Debian- and RHEL-based OS'es, but should work on anything that runs Puppet, due to the nature of custom providers

## Examples
```puppet
# Manage a space
elastic_api::space { 'my_space':
  display_name => 'My Space',
  description  => 'This is my space!',
  initials     => 'MS',
  color        => '#FFFF00',
}

# Manage a Kibana Advanced Setting
elastic_api::advanced_setting { 'dateFormat:dow':
  value => 'Monday',
  space => 'my_space',
}

# Manage a ILM Policy
elastic_api::ilm_policy { '1_week':
  hot_max_age           => '1d',
  hot_max_size          => '50gb',
  warm_number_of_shards => 1,
  cold_enabled          => false,
  delete_min_age        => '7d',
}

# Manage a User Role and User Mapping (e.g. to LDAP realm)
# Create Grafana user role
elastic_api::user_role { 'ldap_grafana_role':
  indices => [{
    'names'                    => ['my_indices*'],
    'privileges'               => ['read', 'monitor', 'view_index_metadata'],
    'allow_restricted_indices' => false,
  }],
}
# Map the Grafana role
elastic_api::user_mapping { 'sa_grafana_role_mapping':
  dn_path => 'CN=Grafana User,OU=ELK,DC=my_domain,DC=org',
  roles   => ['ldap_grafana_role'],
  is_user => true, # Can be a pointed to a Security Group, with this set to false
}
```
