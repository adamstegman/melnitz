# coding: UTF-8

require 'spec_helper'

describe JIRA::Client do
  let(:client_config) { {base_uri: 'http://test.host'} }
  let(:client) { described_class.new(client_config) }

  describe '#fetch_issue(issue_key)' do
    let(:issue_key) { 'ISSUE-1' }

    it 'returns the parsed response body from the issue URL' do
      body = JIRAHelper.issue(issue_key)
      stub_request(:get, "http://test.host/rest/api/latest/issue/#{issue_key}").to_return(body: JSON.generate(body))
      expect(client.fetch_issue(issue_key)).to eq(body)
    end

    it 'returns nil if the issue URL is not found' do
      stub_request(:get, "http://test.host/rest/api/latest/issue/#{issue_key}").to_return(status: 404)
      expect(client.fetch_issue(issue_key)).to be_nil
    end

    it 'raises a service unreachable error for a timeout' do
      stub_request(:get, "http://test.host/rest/api/latest/issue/#{issue_key}").to_timeout
      expect { client.fetch_issue(issue_key) }.to raise_error(JIRA::ServiceUnreachableError)
    end

    it 'raises a service unreachable error for a SocketError' do
      stub_request(:get, "http://test.host/rest/api/latest/issue/#{issue_key}").to_raise(SocketError)
      expect { client.fetch_issue(issue_key) }.to raise_error(JIRA::ServiceUnreachableError)
    end
  end
end
