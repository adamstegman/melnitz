# coding: UTF-8

require 'lib/jira'

Melnitz::Application.class_eval do
  cattr_accessor :jira_client
end

Melnitz::Application.jira_client = JIRA::Client.new
