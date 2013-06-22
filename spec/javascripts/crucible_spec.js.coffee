#= require crucible

describe "Crucible", ->
  describe "#getReview(reviewKey)", ->
    it "resolves with the parsed response body from the review URL", ->
      reviewKey = "PROJECT-CR-1"
      reviewDetails = CrucibleHelper.review reviewKey
      @server.respondWith("GET", "/crucible/reviews/#{reviewKey}", JSON.stringify(reviewDetails))
      client = new Crucible
      reviewPromise = client.getReview(reviewKey)
      actualDetails = undefined
      reviewPromise.done (actual) -> actualDetails = actual
      runs -> @server.respond()
      waitsFor ->
        !!actualDetails
      , "detail promise was never resolved", 100
      runs -> expect(actualDetails).toEqual(reviewDetails)

    it "rejects with an Error if the review is not found", ->
      reviewKey = "PROJECT-CR-1"
      @server.respondWith("GET", "/crucible/reviews/#{reviewKey}", [404, {}, ""])
      client = new Crucible
      reviewPromise = client.getReview(reviewKey)
      error = undefined
      reviewPromise.done undefined, (e) -> error = e
      runs -> @server.respond()
      waitsFor ->
        !!error
      , "promise was never rejected", 100
      runs -> expect(error instanceof Crucible.NotFoundError).toBe(true)

    # TODO: figure out how to test this, and a timeout
    # it "rejects with an Error if the service is unreachable", ->

  beforeEach ->
    @server = sinon.fakeServer.create()

  afterEach ->
    @server.restore()
