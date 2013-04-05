# coding: UTF-8

require 'lib/exchange'

Melnitz::Application.class_eval do
  def exchange_client
    @exchange_client ||= Exchange::Client.new(YAML.load_file(Rails.root.join('config', 'ews.yml')))
  end
end
