# coding: UTF-8

require 'spec_helper'
require 'lib/exchange'

describe Dashboard do
  let(:service) { ExchangeService.new }
  let(:crucible_email) {
    email_message = EmailMessage.new(service)
    email_message.subject = '[Crucible] 1 comment added: (MYPROJECT-CR-1) MYPROJECT-1 [my_project] some issue'
    Email.new(email_message)
  }
  let(:jira_email) {
    email_message = EmailMessage.new(service)
    email_message.subject = 'Issue (MYPROJECT-1) [my_project] some issue'
    Email.new(email_message)
  }
  let(:personal_email) {
    email_message = EmailMessage.new(service)
    email_message.subject = 'Something that could never, ever possibly destroy us'
    Email.new(email_message)
  }
  let(:project_ucern_email) {
    email_message = EmailMessage.new(service)
    email_message.subject = '[Population Health App Infra] - [my_project] some discussion'
    Email.new(email_message)
  }
  let(:ucern_email) {
    email_message = EmailMessage.new(service)
    email_message.subject = '[Population Health App Infra] - some discussion'
    Email.new(email_message)
  }
  let(:ucern_document_email) {
    email_message = EmailMessage.new(service)
    email_message.subject = '[Population Health App Infra] some document (Document added/updated)'
    Email.new(email_message)
  }
  let(:ucern_wiki_email) {
    email_message = EmailMessage.new(service)
    email_message.subject = '[uCern Wiki] My Project > Some Page'
    Email.new(email_message)
  }
  let(:emails) { [crucible_email, jira_email, personal_email, project_ucern_email, ucern_email, ucern_document_email, ucern_wiki_email] }
  let(:dashboard) { Dashboard.new(emails) }

  describe '#personal' do
    it 'returns emails that do not fit in other sections' do
      expect(dashboard.personal).to eq([personal_email])
    end
  end

  describe '#issues' do
    it 'returns emails that pertain to JIRA issues or Crucible reviews' do
      expect(dashboard.issues).to eq([crucible_email, jira_email])
    end
  end

  describe '#projects' do
    it 'returns emails that pertain to projects' do
      expect(dashboard.projects).to eq([crucible_email, jira_email, project_ucern_email])
    end
  end

  describe '#ucern' do
    it 'returns emails that are from or about uCern or uCern Wiki' do
      expect(dashboard.ucern).to eq([project_ucern_email, ucern_email, ucern_document_email, ucern_wiki_email])
    end
  end
end
