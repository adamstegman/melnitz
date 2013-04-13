#= require melnitz/models/email

describe "Melnitz.Email", ->
  describe "#htmlSafeId", ->
    it "escapes characters unsafe for an HTML attribute", ->
      email = new Melnitz.Email({id: "abc-123/456&789"})
      expect(email.htmlSafeId()).toBe("abc-123\\/456\\&789")
