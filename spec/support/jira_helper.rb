# coding: UTF-8

# TODO: use this for the JS tests too somehow instead of jira_helper.coffee
module JIRAHelper
  def self.issue(key, fields = {})
    {
      id: 1, # TODO: generate?
      self: "http://test.host/jira/rest/api/2/issue/1",
      key: key,
      fields: fields
    }.with_indifferent_access
  end
end
