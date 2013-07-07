# coding: UTF-8

require 'json'
require 'net/http'
require 'uri'

module Crucible
  # Public: Global Crucible configuration. Sourced from config/crucible.yml.
  class Config < Settingslogic
    source    Rails.root.join('config', 'crucible.yml')
    namespace Rails.env
  end

  # Public: Crucible 2.9 REST API client.
  #
  # Crucible API documentation: https://docs.atlassian.com/fisheye-crucible/2.9.1/wadl/crucible.html
  #
  # TODO: test with other Crucible API versions
  class Client
    # Public: Retrieves details about the review identified by the given key.
    #
    # review_key - A review key, e.g. "MYISSUE-CR-1".
    #
    # Returns a Hash with String keys with the resulting review data, or nil if the review is not found.
    # Raises a ServiceUnreachableError if the Crucible service is unreachable or times out.
    def fetch_review(review_key)
      # TODO: request specific fields
      uri = URI.parse("#{base_uri}/reviews-v1/#{review_key}")
      response = get(uri.path)
      JSON.parse(response.body) if response.code == '200'
    rescue SocketError => e
      raise ServiceUnreachableError.new("Unable to reach #{uri}", e)
    rescue Timeout::Error => e
      raise ServiceUnreachableError.new("Timeout when accessing #{uri}", e)
    end

    private

    def base_uri
      @base_uri ||= "#{Config.base_uri}/rest-service"
    end

    def get(path)
      request = Net::HTTP::Get.new(path)
      request['Accept'] = 'application/json'
      http.request(request)
    end

    def http
      return @http if @http
      uri = URI.parse(base_uri)
      @http = Net::HTTP.new(uri.host, uri.port)
    end
  end

  # Public: The Crucible service is unreachable.
  #
  # The causing exception is reachable at #nested.
  class ServiceUnreachableError < Nesty::NestedStandardError
  end
end
