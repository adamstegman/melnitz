# coding: UTF-8

module EmailSummaryRepresenter
  include Roar::Representer::JSON::HAL

  property :id
  property :subject

  link :self do |email|
    email_url(self.url_escaped_id)
  end
end
