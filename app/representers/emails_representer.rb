# coding: UTF-8

module EmailsRepresenter
  include Roar::Representer::JSON::HAL

  collection :emails, class: Email, extend: EmailSummaryRepresenter, embedded: true

  link :self do
    @self_url
  end

  private

  def emails
    each
  end
end
