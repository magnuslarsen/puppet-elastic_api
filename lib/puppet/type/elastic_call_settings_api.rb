# frozen_string_literal: true

Puppet::Type.newtype(:elastic_call_settings_api) do
  @doc = 'Create or update an advanced setting in Kibana.'

  feature :call_settings_api, 'require rest api', methods: [:call_settings_api]

  ensurable

  newparam(:name, namevar: true) do
    desc 'A unique name for the resource'
  end

  newparam(:http_method) do
    desc 'The method to use against the API when creating resources'

    newvalues(:PUT, :POST)
  end

  newparam(:setting) do
    desc 'The setting you want to set'
  end

  newproperty(:payload) do
    desc 'The payload to deploy'

    def insync?(is)
      is == should
    end
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
