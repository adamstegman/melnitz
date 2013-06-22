# coding: UTF-8

require 'spec_helper'

describe Jira::IssueController do
  describe 'GET "show"' do
    let(:issue_key) { 'ISSUE-1' }

    it 'returns the issue details from the JIRA service' do
      issue_details = JIRAHelper.issue(issue_key)
      issue_json = JSON.generate(issue_details)
      stub_request(:get, "http://test.host/rest/api/latest/issue/#{issue_key}").to_return(body: issue_json)
      get :show, id: issue_key
      expect(response).to be_success
      expect(response.body).to eq(issue_json)
    end

    it 'returns a 404 if the issue is not found' do
      stub_request(:get, "http://test.host/rest/api/latest/issue/#{issue_key}").to_return(status: 404)
      get :show, id: issue_key
      expect(response.status).to eq(404)
    end

    it 'returns a 503 if the service times out' do
      stub_request(:get, "http://test.host/rest/api/latest/issue/#{issue_key}").to_raise(Timeout::Error)
      get :show, id: issue_key
      expect(response.status).to eq(503)
    end

    it 'returns a 503 if the service is unreachable' do
      stub_request(:get, "http://test.host/rest/api/latest/issue/#{issue_key}").to_raise(SocketError)
      get :show, id: issue_key
      expect(response.status).to eq(503)
    end
  end
end
