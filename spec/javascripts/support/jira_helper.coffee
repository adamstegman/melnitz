@JIRAHelper =
  issue: (key, fields = {}) ->
    id: 1 # TODO: generate?
    self: "http://test.host/jira/rest/api/2/issue/1"
    key: key
    fields: fields
