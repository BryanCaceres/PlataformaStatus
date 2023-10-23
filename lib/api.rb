require 'faraday_middleware'

class Api
  def initialize(token, domain)
    @token = token
    @api_server = domain
  end

  def send(http_method, path, params={})
    request(http_method: http_method.to_sym, endpoint: path, params: params)
  end

  def send_file(http_method, path, params={})
    file_request(http_method: http_method.to_sym, endpoint: path, params: params)
  end

  private

  def client
    Faraday.new(
      url: @api_server,
      headers: {
        'Accept' => 'application/json',
        'Content-Type' => 'application/json',
        'Authorization' => "Bearer #{@token}"
      }
    ) do |conn|
      conn.response :json, content_type: /\bjson$/
      conn.response :logger, ::Logger.new(STDOUT), bodies: true
      conn.adapter Faraday.default_adapter
    end
  end

  def request(http_method:, endpoint:, params: {})
    response = client.public_send(http_method, endpoint, params)
    handle_response(response)
  end

  def file_client
    Faraday.new(
      url: @api_server,
      headers: {
        'Accept' => 'application/json',
        'Content-Type' => 'multipart/form-data',
        'Authorization' => "Bearer #{@token}"
      }
    ) do |conn|
      conn.request :multipart
      conn.response :json, content_type: /\bjson$/
      conn.response :logger, ::Logger.new(STDOUT), bodies: true
      conn.adapter Faraday.default_adapter
    end
  end

  def file_request(http_method:, endpoint:, params: {})
    response = file_client.public_send(http_method, endpoint, params)
    handle_response(response)
  end

  def handle_response(response)
    unless [200, 201].include?(response.status)
      return {"statusCode" => response.status, "message" => response.body["message"] || response.body["msg"]}
    end

    response.body
  rescue Faraday::Error => error
    {"statusCode" => 500, "message" => error.message}
  end
end