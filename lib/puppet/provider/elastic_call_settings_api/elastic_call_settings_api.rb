# frozen_string_literal: true

require 'json'
require 'net/http'
require 'openssl'

Puppet::Type.type(:elastic_call_settings_api).provide(:call_settings_api) do
  # Sends a REST request, with the specified parameters
  def send_request(method, host, url_path, username, password, payload = nil)
    payload = payload.to_json unless payload.nil?
    method  = method.to_s

    url = URI("#{host}/#{url_path}")

    http             = Net::HTTP.new(url.host, url.port)
    http.use_ssl     = url.scheme == 'https'
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = case method
              when 'POST' then Net::HTTP::Post.new(url)
              when 'PUT' then Net::HTTP::Put.new(url)
              when 'GET' then Net::HTTP::Get.new(url)
              end

    request['accept']       = 'application/json'
    request['content-type'] = 'application/json'
    request['kbn-xsrf']     = true
    request.body            = payload unless payload.nil?
    request.basic_auth username, password

    response = http.request(request)

    raise Puppet::Error, "Error in REST request: #{response.code} - #{response.response} - #{response.body}" \
      unless response.is_a?(Net::HTTPSuccess) || response.is_a?(Net::HTTPNotFound)

    return response if method == 'GET'
  end

  def find_setting(setting)
    response = send_request 'GET', resource[:host], resource[:url_path], resource[:username], resource[:password]

    all_settings = JSON.parse(response.body)['settings']

    return nil if all_settings[setting].nil?

    # Replicate the request body, to easier manage the resource in puppet
    # (the actual compare is now really easy)
    {
      'changes' => {
        setting => all_settings[setting]['userValue'],
      },
    }
  end

  # OVERRIDDEN PUPPET FUNCTIONS #
  def payload
    find_setting(resource[:setting])
  end

  def payload=(value)
    send_request resource[:http_method], resource[:host], resource[:url_path], resource[:username], resource[:password], value
  end

  def exists?
    !find_setting(resource[:setting]).nil?
  end

  def create
    send_request resource[:http_method], resource[:host], resource[:url_path], resource[:username], resource[:password], resource[:payload]
  end

  def destroy
    send_request resource[:http_method], resource[:host], resource[:url_path], resource[:username], resource[:password], 'changes' => { resource[:setting] => nil }
  end
end
