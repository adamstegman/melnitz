# coding: UTF-8

require 'spec_helper'
require 'lib/exchange'

java_import microsoft.exchange.webservices.data.BodyType,
            microsoft.exchange.webservices.data.EmailAddress,
            microsoft.exchange.webservices.data.MessageBody

describe Email do
  let(:email_message) { EmailMessage.new(ExchangeService.new) }
  let(:email) { Email.new(email_message) }

  describe '#id' do
    it 'returns the ItemId of the email message' do
      # EmailMessage has no #setId method so have to stub it
      email_message.stub(:id).and_return(ItemId.new('abc123'))
      expect(email.id).to eq('abc123')
    end
  end

  describe '#bcc' do
    it 'returns the list of email address blind-carbon-copied on the email message' do
      # can't construct an EmailAddressCollection, so have to mock it
      recipients = [EmailAddress.new('peter@venkman.org'), EmailAddress.new('ray@stantz.com')]
      # EmailMessage has no #setBccRecipients method so have to stub it
      email_message.stub(:bcc_recipients).and_return(recipients)
      expect(email.bcc).to eq(['peter@venkman.org', 'ray@stantz.com'])
    end
  end

  context 'with an HTML body' do
    let(:body) {
      <<-HTML
<!DOCTYPE html>
<html>
<head></head>
<body>
  <p>Janine, you're beautiful when you drive.</p>
</body>
</html>
      HTML
    }

    before(:each) do
      email_message.body = MessageBody.new(BodyType::HTML, body)
    end

    describe '#body' do
      it 'returns the body of the email message' do
        expect(email.body).to eq(body)
      end
    end

    describe '#body_type' do
      it 'returns text' do
        expect(email.body_type).to eq('HTML')
      end
    end
  end

  context 'with a plaintext body' do
    let(:body) { "Janine, you're beautiful when you drive." }

    before(:each) do
      email_message.body = MessageBody.new(BodyType::Text, body)
    end

    describe '#body' do
      it 'returns the body of the email message' do
        expect(email.body).to eq(body)
      end
    end

    describe '#body_type' do
      it 'returns text' do
        expect(email.body_type).to eq('Text')
      end
    end
  end

  describe '#cc' do
    it 'returns the list of email address carbon-copied on the email message' do
      # can't construct an EmailAddressCollection, so have to mock it
      recipients = [EmailAddress.new('dana@barett.net'), EmailAddress.new('winston@zeddemore.us')]
      # EmailMessage has no #setCcRecipients method so have to stub it
      email_message.stub(:cc_recipients).and_return(recipients)
      expect(email.cc).to eq(['dana@barett.net', 'winston@zeddemore.us'])
    end
  end

  describe '#cc_display' do
    it 'returns the formatted display names for the carbon-copy recipients on the email message' do
      # EmailMessage has no #setDisplayCc method so have to stub it
      # TODO: need real data for multiple CC recipients
      email_message.stub(:display_cc).and_return('Barrett,Dana; Zeddemore,Winston')
      expect(email.cc_display).to eq('Barrett,Dana; Zeddemore,Winston')
    end
  end

  describe '#from' do
    it 'returns the email address that the email message is from' do
      email_message.from = EmailAddress.new('egon@spengler.me')
      expect(email.from).to eq('egon@spengler.me')
    end
  end

  describe '#reply_to' do
    it 'returns the list of email addresses to which replies to the email message should be addressed' do
      # can't construct an EmailAddressCollection, so have to mock it
      recipients = [EmailAddress.new('egon@spengler.me'), EmailAddress.new('egon.spengler@me.com')]
      # EmailMessage has no #setReplyTo method so have to stub it
      email_message.stub(:reply_to).and_return(recipients)
      expect(email.reply_to).to eq(['egon@spengler.me', 'egon.spengler@me.com'])
    end
  end

  describe '#sender' do
    it 'returns the email address that sent the email message' do
      email_message.sender = EmailAddress.new('egon@spengler.me')
      expect(email.sender).to eq('egon@spengler.me')
    end
  end

  describe '#size' do
    it 'returns the size of the email in bytes' do
      # EmailMessage has no #setSize method so have to stub it
      email_message.stub(:size).and_return(1024)
      expect(email.size).to eq(1024)
    end
  end

  describe '#subject' do
    it 'returns the subject of the email message' do
      email_message.subject = 'Melnitz'
      expect(email.subject).to eq('Melnitz')
    end
  end

  describe '#to' do
    it 'returns the list of email address the email message was addressed to' do
      # can't construct an EmailAddressCollection, so have to mock it
      recipients = [EmailAddress.new('janine@melnitz.me'), EmailAddress.new('janine.melnitz@me.com')]
      # EmailMessage has no #setToRecipients method so have to stub it
      email_message.stub(:to_recipients).and_return(recipients)
      expect(email.to).to eq(['janine@melnitz.me', 'janine.melnitz@me.com'])
    end
  end

  describe '#to_display' do
    it 'returns the formatted display names for the recipients on the email message' do
      # EmailMessage has no #setDisplayTo method so have to stub it
      # TODO: need real data for multiple recipients
      email_message.stub(:display_to).and_return('Melnitz,Janine; Melnitz,Janine')
      expect(email.to_display).to eq('Melnitz,Janine; Melnitz,Janine')
    end
  end
end
