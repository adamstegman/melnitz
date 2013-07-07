# coding: UTF-8

require 'lib/crucible'

Melnitz::Application.class_eval do
  cattr_accessor :crucible_client
end

Melnitz::Application.crucible_client = Crucible::Client.new
