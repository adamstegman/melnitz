# coding: UTF-8

module EmailsRepresenter
  include Roar::Representer::JSON::HAL

  collection :emails, class: Email, extend: EmailSummaryRepresenter, embedded: true

  link :self do
    url
  end
end
