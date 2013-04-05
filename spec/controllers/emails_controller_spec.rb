# coding: UTF-8

require 'spec_helper'
require 'lib/exchange'

java_import microsoft.exchange.webservices.data.BodyType,
            microsoft.exchange.webservices.data.EmailAddress,
            microsoft.exchange.webservices.data.MessageBody

describe EmailsController do
  let(:email_message) {
    email_message = EmailMessage.new(ExchangeService.new)
    email_message.stub(:id).and_return('test-email-id')
    email_message.stub(:bcc_recipients).and_return([])
    email_message.body = MessageBody.new(BodyType::Text, "Janine, you're beautiful when you drive.")
    email_message.stub(:cc_recipients).and_return([])
    email_message.stub(:display_cc).and_return('')
    email_message.stub(:display_to).and_return('Melnitz,Janine')
    email_message.from = EmailAddress.new('egon@spengler.me')
    email_message.stub(:reply_to).and_return([])
    email_message.sender = EmailAddress.new('egon@spengler.me')
    email_message.stub(:size).and_return(1024)
    email_message.subject = '[Population Health App Infra] - (MYPROJECT-1) [my_project] some discussion about an issue'
    email_message.stub(:to_recipients).and_return([EmailAddress.new('janine@melnitz.me')])
    email_message
  }
  let(:exchange_client) { double('exchange client', fetch_all_unread_emails: [email_message], fetch_email_details: email_message) }
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
      expect(response.body).to eq(Emails.new([], personal_emails_url).extend(EmailsRepresenter).to_json)
    end
  end

  describe 'GET "issues"' do
    it 'returns http success' do
      get :issues
      expect(response).to be_success
      expect(response.body).to eq(Emails.new([Email.new(email_message)], issues_emails_url).extend(EmailsRepresenter).to_json)
    end
  end

  describe 'GET "projects"' do
    it 'returns http success' do
      get :projects
      expect(response).to be_success
      expect(response.body).to eq(Emails.new([Email.new(email_message)], projects_emails_url).extend(EmailsRepresenter).to_json)
    end
  end

  describe 'GET "ucern"' do
    it 'returns http success' do
      get :ucern
      expect(response).to be_success
      expect(response.body).to eq(Emails.new([Email.new(email_message)], ucern_emails_url).extend(EmailsRepresenter).to_json)
    end
  end

  describe 'GET "show"' do
    it 'returns http success' do
      get :show, id: 'test-email-id'
      expect(response).to be_success
      expect(response.body).to eq(Email.new(email_message).extend(EmailRepresenter).to_json)
    end
  end

end
