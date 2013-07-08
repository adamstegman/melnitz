#= require melnitz/views/issue_thread

describe "Melnitz.IssueThread", ->
  describe "#id", ->
    it "returns the thread issue key", ->
      thread = new Melnitz.IssueThread({subject: "some subject"})
      thread.issueKey = "SOMETHING-1"
      expect(thread.id()).toBe("SOMETHING-1")

    it "returns the HTML-escaped subject when the issue key is not set", ->
      thread = new Melnitz.IssueThread({subject: "some subject"})
      thread.issueKey = undefined
      expect(thread.id()).toBe("some\\ subject")

  describe "#setIssueDetails", ->
    it "assigns issueDetails", ->
      issueDetails = JIRAHelper.issue "PROJECT-1"
      thread = new Melnitz.IssueThread
      thread.setIssueDetails issueDetails
      expect(thread.issueDetails).toBe(issueDetails)

    it "assigns issueKey when given issueDetails", ->
      thread = new Melnitz.IssueThread
      thread.setIssueDetails JIRAHelper.issue "PROJECT-1"
      expect(thread.issueKey).toBe("PROJECT-1")
