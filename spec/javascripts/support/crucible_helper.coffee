@CrucibleHelper =
  review: (key, fields = {}) ->
    _.defaults fields,
      permaId:
        id: key
      permaIdHistory: [key]
      projectKey: key.replace(/-\d+$/, '')
      type: "review"
