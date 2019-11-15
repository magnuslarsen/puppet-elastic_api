# frozen_string_literal: true

Puppet::Type.newtype(:elastic_call_api) do
  @doc = 'Create or update a resource in Elasticsearch.'

  feature :call_api, 'require rest api', methods: [:call_api]

  ensurable

  newparam(:name, namevar: true) do
    desc 'A unique name for the resource'
  end

  newparam(:create_http_method) do
    desc 'The method to use against the API when creating resources'

    newvalues(:PUT, :POST)
  end

  newparam(:update_http_method) do
    desc 'The method to use against the API when updating resources'

    newvalues(:PUT, :POST)
  end

  newparam(:is_kibana_endpoint) do
    desc 'Whether the endpoint is the Kibana API or not'

    newvalues(:true, :false)
  end

  newparam(:include_keys, array_matching: :all) do
    desc 'The keys to compare against the output of the API'
  end

  newproperty(:payload) do
    desc 'The payload to deploy'

    def insync?(is)
      is == should
    end
  end

  newparam(:get_url_path) do
    desc 'The URL path to GET the existing configuration'
  end

  newparam(:host) do
    desc 'The host to connect to'
  end

  newparam(:password) do
    desc 'The password to use against the API'
  end

  newparam(:url_path) do
    desc 'The URL path to deploy the payload to'
  end

  newparam(:username) do
    desc 'The username to use against the API'
  end
end
