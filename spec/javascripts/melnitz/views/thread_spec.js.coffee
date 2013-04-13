#= require melnitz/models/email
#= require melnitz/views/thread

describe "Melnitz.Thread", ->
  it "stores the extracted subject of the first given email", ->
    thread = new Melnitz.Thread({emails: [buildEmail({subject: "[Some Group] some discussion"})]})
    expect(thread.subject).toBe("[Some Group] some discussion")

  it "maintains an HTML-attribute-safe version of the subject", ->
    thread = new Melnitz.Thread({emails: [buildEmail({subject: "[Some Group] some discussion"})]})
    expect(thread.htmlSafeSubject).toBe("\\[Some\\ Group\\]\\ some\\ discussion")

  describe "#addEmail", ->
    it "adds the email to the thread", ->
      thread = new Melnitz.Thread
      email = buildEmail()
      thread.addEmail(email)
      expect(_.isEqual(thread.emails, {abc123: email})).toBe(true)

    it "replaces an existing email with the same id", ->
      email = buildEmail()
      thread = new Melnitz.Thread({emails: [email]})
      thread.addEmail(email)
      expect(_.isEqual(thread.emails, {abc123: email})).toBe(true)

    it "fires an addEmail event if the email is new", ->
      fired = false
      thread = new Melnitz.Thread
      thread.on "thread:addEmail", ->
        fired = true
      email = buildEmail()
      runs ->
        thread.addEmail(email)
      waitsFor(->
        fired
      , "The add event should be fired", 10)
      runs ->
        expect(fired).toBe(true)

    it "does not fire an addEmail event if the email is not new", ->
      fired = false
      doneWaiting = false
      thread = new Melnitz.Thread
      email = buildEmail({id: "abc123"})
      thread.addEmail(email)
      thread.on "thread:addEmail", ->
        fired = true
      runs ->
        setTimeout(->
          doneWaiting = true
        , 50)
        thread.addEmail(email)
      waitsFor(->
        doneWaiting
      , "The add event should be fired", 75)
      runs ->
        expect(fired).toBe(false)

  describe ".extractSubject", ->
    it "removes extraneous sections of the subject", ->
      subject = Melnitz.Thread.extractSubject(new Melnitz.Email({subject: "FW: [Some Group] Re: some discussion"}))
      expect(subject).toBe("[Some Group] some discussion")

    it "maintains repeated words and spaces in the common subject", ->
      subject = Melnitz.Thread.extractSubject(new Melnitz.Email({subject: "FW: RE: words some words  repeated words words"}))
      expect(subject).toBe("words some words  repeated words words")

buildEmail = (attributes = {}) ->
  attributes.id ?= "abc123"
  attributes.subject ?= "a subject"
  new Melnitz.Email(attributes)
