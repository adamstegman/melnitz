# coding: UTF-8

require 'spec_helper'
require 'lib/crucible'

describe Crucible::Client do
  let(:client_config) { {base_uri: 'http://test.host'} }
  let(:client) { described_class.new(client_config) }

  describe '#fetch_review(review_key)' do
    let(:review_key) { 'ISSUE-CR-1' }

    it 'returns the parsed response body from the review URL' do
      body = CrucibleHelper.review(review_key)
      stub_request(:get, "http://test.host/rest-service/reviews-v1/#{review_key}").to_return(body: JSON.generate(body))
      expect(client.fetch_review(review_key)).to eq(body)
    end

    it 'returns nil if the review URL is not found' do
      stub_request(:get, "http://test.host/rest-service/reviews-v1/#{review_key}").to_return(status: 404)
      expect(client.fetch_review(review_key)).to be_nil
    end

    it 'raises a service unreachable error for a timeout' do
      stub_request(:get, "http://test.host/rest-service/reviews-v1/#{review_key}").to_timeout
      expect { client.fetch_review(review_key) }.to raise_error(Crucible::ServiceUnreachableError)
    end

    it 'raises a service unreachable error for a SocketError' do
      stub_request(:get, "http://test.host/rest-service/reviews-v1/#{review_key}").to_raise(SocketError)
      expect { client.fetch_review(review_key) }.to raise_error(Crucible::ServiceUnreachableError)
    end
  end
end
