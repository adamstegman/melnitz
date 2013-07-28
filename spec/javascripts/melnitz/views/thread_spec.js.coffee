#= require melnitz/models/email
#= require melnitz/views/thread

describe "Melnitz.Thread", ->
  it "stores the extracted subject of the first given email", ->
    thread = new Melnitz.Thread({emails: [buildEmail({subject: "[Some Group] some discussion"})]})
    expect(thread.subject).toBe("[Some Group] some discussion")

  it "accepts a subject in the constructor", ->
    thread = new Melnitz.Thread
      emails: [buildEmail({subject: "[Some Group] some discussion"})]
      subject: "suggested subject"
    expect(thread.subject).toBe("suggested subject")

  describe "#addEmail", ->
    it "adds the email to the thread", ->
      thread = new Melnitz.Thread
      email = buildEmail()
      thread.addEmail(email)
      expect(thread.includesEmail(email)).toBe(true)

    it "replaces an existing email with the same id", ->
      email = buildEmail()
      thread = new Melnitz.Thread({emails: [email]})
      thread.addEmail(email)
      expect(thread.includesEmail(email)).toBe(true)

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

  describe "#id", ->
    it "returns the HTML-escaped subject", ->
      thread = new Melnitz.Thread
      thread.subject = "some/subject&with=special characters"
      expect(thread.id()).toBe("some\\/subject\\&with\\=special\\ characters")

  describe "#includesEmail", ->
    it "is true for an email that has been added", ->
      thread = new Melnitz.Thread
      email = buildEmail()
      thread.addEmail(email)
      expect(thread.includesEmail(email)).toBe(true)

    it "is false for an email that has not been added", ->
      thread = new Melnitz.Thread
      email = buildEmail()
      expect(thread.includesEmail(email)).toBe(false)

  describe ".extractSubject", ->
    it "removes extraneous sections of the subject", ->
      subject = Melnitz.Thread.extractSubject(new Melnitz.Email({subject: "FW: [Some Group] Re: some discussion"}))
      expect(subject).toBe("[Some Group] some discussion")

    it "maintains repeated words and spaces in the common subject", ->
      subject = Melnitz.Thread.extractSubject(new Melnitz.Email({subject: "FW: RE: words some words  repeated words words"}))
      expect(subject).toBe("words some words  repeated words words")

    it "ignores a prepended 'Canceled:' from the subject", ->
      subject = Melnitz.Thread.extractSubject(new Melnitz.Email({subject: "Canceled: some event"}))
      expect(subject).toBe("some event")

    it "ignores a trailing parenthetical from the subject", ->
      subject = Melnitz.Thread.extractSubject(new Melnitz.Email({subject: "[Some Group] some document (New Comment)"}))
      expect(subject).toBe("[Some Group] some document")

buildEmail = (attributes = {}) ->
  attributes.id ?= "abc123"
  attributes.subject ?= "a subject"
  new Melnitz.Email(attributes)
