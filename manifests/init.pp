# In this class, it is possible to change the defauls values across
# all defined resources in this module
#
# @summary Change default values
#
# @example
#   class { '::elastic_api':
#     elastic_host => $elastic_cluster_ip,
#     kibana_host  => $elastic_cluster_ip,
#     username     => $api_user,
#     password     => $api_pass,
#   }
#
# @param $elastic_host The elasticsearch host to connect to (format: HTTP_PROTO://FQDN:PORT)
# @param $kibana_host  The kibana host to connect to (format: HTTP_PROTO://FQDN:PORT)
# @param $password     The password to use against the API
# @param $username     The username to use against the API
#
class elastic_api (
  String $elastic_host,
  String $kibana_host,
  String $password,
  String $username,
) {

}
