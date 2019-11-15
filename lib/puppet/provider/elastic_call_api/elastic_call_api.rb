# frozen_string_literal: true

require 'json'
require 'net/http'
require 'openssl'

Puppet::Type.type(:elastic_call_api).provide(:call_api) do
  # Sends a REST request, with the specified parameters
  def send_request(method, host, url_path, username, password, is_kibana_endpoint, payload = nil)
    payload = payload.to_json unless payload.nil?
    method  = method.to_s

    url = URI("#{host}/#{url_path}")

    http             = Net::HTTP.new(url.host, url.port)
    http.use_ssl     = url.scheme == 'https'
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = case method
              when 'DELETE' then Net::HTTP::Delete.new(url)
              when 'POST' then Net::HTTP::Post.new(url)
              when 'PUT' then Net::HTTP::Put.new(url)
              when 'GET' then Net::HTTP::Get.new(url)
              end

    request['accept']       = 'application/json'
    request['content-type'] = 'application/json'
    request['kbn-xsrf']     = true if is_kibana_endpoint
    request.body            = payload unless payload.nil?
    request.basic_auth username, password

    response = http.request(request)

    raise Puppet::Error, "Error in REST request: #{response.code} - #{response.response} - #{response.body}" \
      unless response.is_a?(Net::HTTPSuccess) || response.is_a?(Net::HTTPNotFound)

    return response if method == 'GET'
  end

  # OVERRIDDEN PUPPET FUNCTIONS #
  def payload
    response = send_request 'GET', resource[:host], resource[:get_url_path], resource[:username], resource[:password], resource[:is_kibana_endpoint]

    if response.is_a?(Net::HTTPNotFound)
      []
    else
      # Return only the values that we want.
      # This will make it so empty values defaulted by Elasticsearch, doesn't mess with the compare
      # Elasticsearch GET's returns with a toplevel field of $name, Kibana doesn't
      body = JSON.parse(response.body)

      if resource[:include_keys].nil?
        body
      elsif !body[resource[:name]].nil?
        body[resource[:name]].keep_if { |key, _| resource[:include_keys].include?(key) }
      else
        body.keep_if { |key, _| resource[:include_keys].include?(key) }
      end
    end
  end

  def payload=(value)
    send_request resource[:update_http_method], resource[:host], resource[:url_path], resource[:username], resource[:password], resource[:is_kibana_endpoint], value
  end

  def exists?
    response = send_request 'GET', resource[:host], resource[:get_url_path], resource[:username], resource[:password], resource[:is_kibana_endpoint]

    !response.is_a?(Net::HTTPNotFound)
  end

  def create
    send_request resource[:create_http_method], resource[:host], resource[:url_path], resource[:username], resource[:password], resource[:is_kibana_endpoint], resource[:payload]
  end

  def destroy
    send_request 'DELETE', resource[:host], resource[:url_path], resource[:username], resource[:password], resource[:is_kibana_endpoint]
  end
end
