# coding: UTF-8

module DashboardRepresenter
  include Roar::Representer::JSON::HAL

  collection :personal, class: Email, extend: EmailSummaryRepresenter, embedded: true
  collection :issues, class: Email, extend: EmailSummaryRepresenter, embedded: true
  collection :projects, class: Email, extend: EmailSummaryRepresenter, embedded: true
  collection :ucern, class: Email, extend: EmailSummaryRepresenter, embedded: true

  link :self do
    emails_url
  end
end
