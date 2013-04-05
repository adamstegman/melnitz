# coding: UTF-8

require 'spec_helper'
require 'lib/exchange'

describe EmailsController do
  let(:email_message) {
    email_message = EmailMessage.new(ExchangeService.new)
    email_message.subject = '[Population Health App Infra] - (MYPROJECT-1) [my_project] some discussion about an issue'
    email_message
  }
  let(:exchange_client) { double('exchange client', fetch_all_unread_emails: [email_message]) }
  before(:each) do
    request.accept = 'application/json'
    Rails.application.instance_variable_set('@exchange_client', exchange_client)
  end

  describe 'GET "index"' do
    it 'returns all unread emails' do
      get :index
      expect(response).to be_success
      expect(response.body).to eq(Dashboard.new([Email.new(email_message)]).extend(DashboardRepresenter).to_json)
    end
  end

  describe 'GET "personal"' do
    it 'returns http success' do
      get :personal
      expect(response).to be_success
    end
  end

  describe 'GET "issues"' do
    it 'returns http success' do
      get :issues
      expect(response).to be_success
    end
  end

  describe 'GET "projects"' do
    it 'returns http success' do
      get :projects
      expect(response).to be_success
    end
  end

  describe 'GET "ucern"' do
    it 'returns http success' do
      get :ucern
      expect(response).to be_success
    end
  end

  describe 'GET "show"' do
    it 'returns http success' do
      # FIXME
      get :show, id: 'test'
      expect(response).to be_success
    end
  end

end
