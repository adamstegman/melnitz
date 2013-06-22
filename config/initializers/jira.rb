# coding: UTF-8

require 'lib/jira'

config = YAML.load_file(Rails.root.join('config', 'jira.yml'))

if config && (jira_config = config[Rails.env])
  Melnitz::Application.class_eval do
    cattr_accessor :jira_client
  end

  Melnitz::Application.jira_client = JIRA::Client.new(jira_config.with_indifferent_access)
else
  raise 'Could not load JIRA configuration'
end
