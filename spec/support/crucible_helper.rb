# coding: UTF-8

# TODO: use this for the JS tests too somehow instead of crucible_helper.coffee
module CrucibleHelper
  def self.review(key, fields = {})
    {
      permaId: {
        id: key
      },
      permaIdHistory: [key],
      projectKey: key.sub(/-\d+\z/, ''),
      type: 'review'
    }.merge(fields).with_indifferent_access
  end
end
