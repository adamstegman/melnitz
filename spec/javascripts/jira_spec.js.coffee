#= require jira

describe "JIRA", ->
  describe "#getIssue(issueKey, attributes...)", ->
    it "resolves with the parsed response body from the issue URL", ->
      issueKey = "PROJECT-1"
      issueDetails = JIRAHelper.issue issueKey
      @server.respondWith("GET", "/jira/issue/#{issueKey}", JSON.stringify(issueDetails))
      client = new JIRA
      issuePromise = client.getIssue(issueKey)
      actualDetails = undefined
      issuePromise.done (actual) -> actualDetails = actual
      runs -> @server.respond()
      waitsFor ->
        !!actualDetails
      , "detail promise was never resolved", 100
      runs -> expect(actualDetails).toEqual(issueDetails)

    it "rejects with an Error if the issue is not found", ->
      issueKey = "PROJECT-1"
      @server.respondWith("GET", "/jira/issue/#{issueKey}", [404, {}, ""])
      client = new JIRA
      issuePromise = client.getIssue(issueKey)
      error = undefined
      issuePromise.done undefined, (e) -> error = e
      runs -> @server.respond()
      waitsFor ->
        !!error
      , "promise was never rejected", 100
      runs -> expect(error instanceof JIRA.NotFoundError).toBe(true)

    # TODO: figure out how to test this, and a timeout
    # it "rejects with an Error if the service is unreachable", ->

  beforeEach ->
    @server = sinon.fakeServer.create()

  afterEach ->
    @server.restore()
