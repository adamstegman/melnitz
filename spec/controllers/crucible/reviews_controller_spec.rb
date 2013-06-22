# coding: UTF-8

require 'spec_helper'

describe Crucible::ReviewsController do
  describe 'GET "show"' do
    let(:review_key) { 'ISSUE-CR-1' }

    it 'returns the review details from the Crucible service' do
      review_details = CrucibleHelper.review(review_key)
      review_json = JSON.generate(review_details)
      stub_request(:get, "http://test.host/rest-service/reviews-v1/#{review_key}").to_return(body: review_json)
      get :show, id: review_key
      expect(response).to be_success
      expect(response.body).to eq(review_json)
    end

    it 'returns a 404 if the review is not found' do
      stub_request(:get, "http://test.host/rest-service/reviews-v1/#{review_key}").to_return(status: 404)
      get :show, id: review_key
      expect(response.status).to eq(404)
    end

    it 'returns a 503 if the service times out' do
      stub_request(:get, "http://test.host/rest-service/reviews-v1/#{review_key}").to_raise(Timeout::Error)
      get :show, id: review_key
      expect(response.status).to eq(503)
    end

    it 'returns a 503 if the service is unreachable' do
      stub_request(:get, "http://test.host/rest-service/reviews-v1/#{review_key}").to_raise(SocketError)
      get :show, id: review_key
      expect(response.status).to eq(503)
    end
  end
end
