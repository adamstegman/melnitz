# coding: UTF-8

module EmailRepresenter
  include Roar::Representer::JSON::HAL

  property :id
  property :bcc
  property :body
  property :body_type
  property :cc
  property :cc_display
  property :from
  property :reply_to
  property :sender
  property :size
  property :subject
  property :to
  property :to_display

  link :self do
    email_url(self.url_escaped_id)
  end
end
