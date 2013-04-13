#= require html_util

describe "HTMLUtil", ->
  describe ".escapeAttr", ->
    it "escapes characters unsafe for usage in an HTML attribute", ->
      expect(HTMLUtil.escapeAttr("abc-123/456&789")).toBe("abc-123\\/456\\&789")

    it "returns undefined when given null", ->
      expect(HTMLUtil.escapeAttr(null)).not.toBeDefined()

  describe ".unescapeAttr", ->
    it "unescapes backslash-escaped characters", ->
      expect(HTMLUtil.unescapeAttr("abc-123\\/456\\&789")).toBe("abc-123/456&789")

    it "returns undefined when given null", ->
      expect(HTMLUtil.unescapeAttr(null)).not.toBeDefined()
