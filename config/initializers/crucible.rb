# coding: UTF-8

require 'lib/crucible'

config = YAML.load_file(Rails.root.join('config', 'crucible.yml'))

if config && (crucible_config = config[Rails.env])
  Melnitz::Application.class_eval do
    cattr_accessor :crucible_client
  end

  Melnitz::Application.crucible_client = Crucible::Client.new(crucible_config.with_indifferent_access)
else
  raise 'Could not load Crucible configuration'
end
