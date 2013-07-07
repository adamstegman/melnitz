# coding: UTF-8

require 'json'
require 'net/http'
require 'uri'

module JIRA
  # Public: Global JIRA configuration. Sourced from config/jira.yml.
  class Config < Settingslogic
    source    Rails.root.join('config', 'jira.yml')
    namespace Rails.env
  end

  # Public: JIRA 5.2 REST API client.
  #
  # JIRA API documentation: http://docs.atlassian.com/jira/REST/latest/
  #
  # TODO: test with other JIRA API versions
  class Client
    # Public: Retrieves details about the issue identified by the given key.
    #
    # issue_key - An issue key, which can be either the full issue key String (e.g. "MYISSUE-1") or the issue id
    #             Integer (e.g. 57938).
    #
    # Returns a Hash with String keys with the resulting issue data, or nil if the issue is not found.
    # Raises a ServiceUnreachableError if the JIRA service is unreachable or times out.
    def fetch_issue(issue_key)
      # TODO: request specific fields
      uri = URI.parse("#{base_uri}/issue/#{issue_key}")
      response = get(uri.path)
      JSON.parse(response.body) if response.code == '200'
    rescue SocketError => e
      raise ServiceUnreachableError.new("Unable to reach #{uri}", e)
    rescue Timeout::Error => e
      raise ServiceUnreachableError.new("Timeout when accessing #{uri}", e)
    end

    private

    def base_uri
      @base_uri ||= "#{Config.base_uri}/rest/api/latest"
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

  # Public: The JIRA service is unreachable.
  #
  # The causing exception is reachable at #nested.
  class ServiceUnreachableError < Nesty::NestedStandardError
  end
end
