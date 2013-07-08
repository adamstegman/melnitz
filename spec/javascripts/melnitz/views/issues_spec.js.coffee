#= require q
#= require melnitz/collections/emails
#= require melnitz/models/email
#= require melnitz/views/issues

fixture.set "<!DOCTYPE html><html><head><title>fixture</title></head><body></body></html>"
describe "Melnitz.Issues", ->
  beforeEach ->
    @mockJIRAClient =
      getIssue: (issueKey) -> this[issueKey]
    @mockCrucibleClient =
      getReview: (reviewKey) -> this[reviewKey]

  describe "#threadList", ->
    it "prioritizes threads based on my JIRA activity", ->
      assignedSubtask = "Issue (PROJECT-5) [some_component] summary"
      assignedParent = "Issue (PROJECT-4) [project] summary"
      commentedStory = "Issue (PROJECT-1) [project] summary"
      untouched = "Issue (PROJECT-3) [some_other_component] summary"
      assignedSubtaskEmail = new Melnitz.Email({id: 'assignedSubtask', subject: assignedSubtask})
      assignedParentEmail = new Melnitz.Email({id: 'assignedParent', subject: assignedParent})
      commentedStoryEmail = new Melnitz.Email({id: 'commentedStory', subject: commentedStory})
      untouchedEmail = new Melnitz.Email({id: 'untouched', subject: untouched})
      @mockJIRAClient["PROJECT-1"] = Q.fcall -> JIRAHelper.issue "PROJECT-1", {summary: "[project] summary", comment: {comments: [{author: {name: "myName"}}]}}
      @mockJIRAClient["PROJECT-3"] = Q.fcall -> JIRAHelper.issue "PROJECT-3", {summary: "[some_other_component] summary"}
      @mockJIRAClient["PROJECT-4"] = Q.fcall -> JIRAHelper.issue "PROJECT-4", {summary: "[project] summary"}
      @mockJIRAClient["PROJECT-5"] = Q.fcall -> JIRAHelper.issue "PROJECT-5", {summary: "[some_component] summary", assignee: {name: "myName"}, parent: {key: "PROJECT-4", fields: {summary: "[project] summary"}}}
      issues = new Melnitz.Issues({crucible: {client: @mockCrucibleClient}, jira: {client: @mockJIRAClient, username: "myName"}})
      issues.collection = new Melnitz.Emails([assignedSubtaskEmail, assignedParentEmail, commentedStoryEmail, untouchedEmail])

      expectedThreadList = [
        {subject: "PROJECT-4: [project] summary", emails: {assignedParent: assignedParentEmail, assignedSubtask: assignedSubtaskEmail}},
        {subject: "PROJECT-1: [project] summary", emails: {commentedStory: commentedStoryEmail}},
        {subject: "PROJECT-3: [some_other_component] summary", emails: {untouched: untouchedEmail}}
      ]
      runs -> issues.updateThreads()
      waitsFor _.bind(isEmailCategorized, this, issues, 4), "should have added all emails to threads", 500
      runs ->
        actualThreadList = issues.threadList()
        expect(actualThreadList.length).toBe(expectedThreadList.length)
        _.each actualThreadList, (thread, index) ->
          expect(thread.subject).toEqual(expectedThreadList[index].subject)
          expect(thread.emails).toEqual(expectedThreadList[index].emails)

  describe "#updateThreads", ->
    it "groups issues by parent", ->
      # Emails from parent and subtasks
      subtask2 = "Issue (PROJECT-2) [some_component] summary"
      subtask3 = "Issue (PROJECT-3) [some_other_component] summary"
      parent = "Issue (PROJECT-1) [project] summary"
      subtask2Email = new Melnitz.Email({id: 'subtask2', subject: subtask2})
      subtask3Email = new Melnitz.Email({id: 'subtask3', subject: subtask3})
      parentEmail = new Melnitz.Email({id: 'parent', subject: parent})
      @mockJIRAClient["PROJECT-1"] = Q.fcall -> JIRAHelper.issue "PROJECT-1", {summary: "[project] summary"}
      @mockJIRAClient["PROJECT-2"] = Q.fcall -> JIRAHelper.issue "PROJECT-2", {summary: "[some_component] summary", parent: {key: "PROJECT-1", fields: {summary: "[project] summary"}}}
      @mockJIRAClient["PROJECT-3"] = Q.fcall -> JIRAHelper.issue "PROJECT-3", {summary: "[some_other_component] summary", parent: {key: "PROJECT-1", fields: {summary: "[project] summary"}}}
      issues = new Melnitz.Issues({crucible: {client: @mockCrucibleClient}, jira: {client: @mockJIRAClient}})
      issues.collection = new Melnitz.Emails([subtask2Email, subtask3Email, parentEmail])

      runs -> issues.updateThreads()
      waitsFor _.bind(isEmailCategorized, this, issues, 3), "should have added all emails to threads", 500
      runs ->
        actualThreads = _.values(issues.threads)
        expect(actualThreads.length).toBe(1)
        expect(actualThreads[0].subject).toEqual("PROJECT-1: [project] summary")
        expect(actualThreads[0].emails).toEqual
          parent: parentEmail
          subtask2: subtask2Email
          subtask3: subtask3Email

    it "groups children by a parent that generated no emails", ->
      # Email from a subtask whose parent generated no emails
      lonelyChild = "Issue (PROJECT-4) [other_project] summary"
      childEmail = new Melnitz.Email({id: 'child', subject: lonelyChild})
      @mockJIRAClient["PROJECT-3"] = Q.fcall -> JIRAHelper.issue "PROJECT-3", {summary: "[other_project] summary"}
      @mockJIRAClient["PROJECT-4"] = Q.fcall -> JIRAHelper.issue "PROJECT-4", {summary: "[other_project] summary", parent: {key: "PROJECT-3", fields: {summary: "[other_project] summary"}}}
      issues = new Melnitz.Issues({crucible: {client: @mockCrucibleClient}, jira: {client: @mockJIRAClient}})
      issues.collection = new Melnitz.Emails([childEmail])

      runs -> issues.updateThreads()
      waitsFor _.bind(isEmailCategorized, this, issues, 1), "should have added the email to a thread", 500
      runs ->
        actualThreads = _.values(issues.threads)
        expect(actualThreads.length).toBe(1)
        expect(actualThreads[0].subject).toEqual("PROJECT-3: [other_project] summary")
        expect(actualThreads[0].emails).toEqual {child: childEmail}

    it "handles a bad JIRA response", ->
      # Email from a subtask whose parent generated no emails
      movedChild = "Issue (PROJECT-5) [wrong_project] summary"
      childEmail = new Melnitz.Email({id: 'child', subject: movedChild})
      @mockJIRAClient["PROJECT-5"] = Q.fcall -> throw new JIRA.NotFoundError
      issues = new Melnitz.Issues({crucible: {client: @mockCrucibleClient}, jira: {client: @mockJIRAClient}})
      issues.collection = new Melnitz.Emails([childEmail])

      runs -> issues.updateThreads()
      waitsFor _.bind(isEmailCategorized, this, issues, 1), "should have added the email to a thread", 500
      runs ->
        actualThreads = _.values(issues.threads)
        expect(actualThreads.length).toBe(1)
        expect(actualThreads[0].subject).toEqual(movedChild)
        expect(actualThreads[0].emails).toEqual {child: childEmail}

    it "groups related JIRA issues and Crucible reviews together", ->
      # Emails from parent and subtasks
      subtask2 = "Issue (PROJECT-2) [some_component] summary"
      subtask3 = "Issue (PROJECT-3) [some_other_component] summary"
      subtask3Review = "[Crucible] 5 comments added: (PROJECT-CR-2) PROJECT-3 [some_other_component] summary"
      parent = "Issue (PROJECT-1) [project] summary"
      parentReview = "[Crucible] 2 comments added: (PROJECT-CR-1) PROJECT-1 [project] summary"
      someOtherReview = "[Crucible] 3 comments added: (PROJECT-CR-3) PROJECT-4 [something] summary"
      subtask2Email = new Melnitz.Email({id: 'subtask2', subject: subtask2})
      subtask3Email = new Melnitz.Email({id: 'subtask3', subject: subtask3})
      subtask3ReviewEmail = new Melnitz.Email({id: 'subtask3Review', subject: subtask3Review})
      parentEmail = new Melnitz.Email({id: 'parent', subject: parent})
      parentReviewEmail = new Melnitz.Email({id: 'parentReview', subject: parentReview})
      someOtherReviewEmail = new Melnitz.Email({id: 'someOtherReview', subject: someOtherReview})
      @mockJIRAClient["PROJECT-1"] = Q.fcall -> JIRAHelper.issue "PROJECT-1", {summary: "[project] summary"}
      @mockJIRAClient["PROJECT-2"] = Q.fcall -> JIRAHelper.issue "PROJECT-2", {summary: "[some_component] summary", parent: {key: "PROJECT-1", fields: {summary: "[project] summary"}}}
      @mockJIRAClient["PROJECT-3"] = Q.fcall -> JIRAHelper.issue "PROJECT-3", {summary: "[some_other_component] summary", parent: {key: "PROJECT-1", fields: {summary: "[project] summary"}}}
      @mockJIRAClient["PROJECT-4"] = Q.fcall -> JIRAHelper.issue "PROJECT-4", {summary: "[something] summary", parent: {key: "PROJECT-5", fields: {summary: "[project] summary"}}}
      @mockJIRAClient["PROJECT-5"] = Q.fcall -> JIRAHelper.issue "PROJECT-5", {summary: "[project] summary"}
      @mockCrucibleClient["PROJECT-CR-1"] = Q.fcall -> CrucibleHelper.review "PROJECT-CR-1", {jiraIssueKey: "PROJECT-1"}
      @mockCrucibleClient["PROJECT-CR-2"] = Q.fcall -> CrucibleHelper.review "PROJECT-CR-2", {jiraIssueKey: "PROJECT-3"}
      @mockCrucibleClient["PROJECT-CR-3"] = Q.fcall -> CrucibleHelper.review "PROJECT-CR-3", {jiraIssueKey: "PROJECT-4"}
      issues = new Melnitz.Issues({crucible: {client: @mockCrucibleClient}, jira: {client: @mockJIRAClient}})
      issues.collection = new Melnitz.Emails([subtask2Email, subtask3Email, parentEmail, subtask3ReviewEmail, parentReviewEmail, someOtherReviewEmail])

      expectedThreads =
        "PROJECT-1: [project] summary":
          parent: parentEmail
          parentReview: parentReviewEmail
          subtask2: subtask2Email
          subtask3: subtask3Email
          subtask3Review: subtask3ReviewEmail
        "PROJECT-5: [project] summary":
          someOtherReview: someOtherReviewEmail
      runs -> issues.updateThreads()
      waitsFor _.bind(isEmailCategorized, this, issues, 6), "should have added all emails to threads", 500
      runs ->
        actualThreads = _.values(issues.threads)
        expect(actualThreads.length).toBe(2)
        _.each actualThreads, (thread) ->
          expect(thread.emails).toEqual(expectedThreads[thread.subject])
          delete expectedThreads[thread.subject]
        # all threads found
        expect(_.size(expectedThreads)).toBe(0)

    it "finds a JIRA key in the Crucible summary if one is not linked", ->
      # Emails from parent and subtasks
      review = "[Crucible] 2 comments added: (PROJECT-CR-1) PROJECT-1 [project] summary"
      reviewEmail = new Melnitz.Email({id: 'review', subject: review})
      @mockJIRAClient["PROJECT-1"] = Q.fcall -> JIRAHelper.issue "PROJECT-1", {summary: "[project] summary"}
      @mockCrucibleClient["PROJECT-CR-1"] = Q.fcall -> CrucibleHelper.review "PROJECT-CR-1", {name: "PROJECT-1 [project] summary"}
      issues = new Melnitz.Issues({crucible: {client: @mockCrucibleClient}, jira: {client: @mockJIRAClient}})
      issues.collection = new Melnitz.Emails([reviewEmail])

      runs -> issues.updateThreads()
      waitsFor _.bind(isEmailCategorized, this, issues, 1), "should have added the email to a thread", 500
      runs ->
        actualThreads = _.values(issues.threads)
        expect(actualThreads.length).toBe(1)
        expect(actualThreads[0].subject).toEqual("PROJECT-1: [project] summary")
        expect(actualThreads[0].emails).toEqual({review: reviewEmail})

    it "includes emails that don't have a recognizable JIRA key", ->
      someSubject = "Blah blah blah"
      email = new Melnitz.Email({id: 'email', subject: someSubject})
      issues = new Melnitz.Issues({crucible: {client: @mockCrucibleClient}, jira: {client: @mockJIRAClient}})
      issues.collection = new Melnitz.Emails([email])

      runs -> issues.updateThreads()
      waitsFor _.bind(isEmailCategorized, this, issues, 1), "should have added the email to a thread", 500
      runs ->
        actualThreads = _.values(issues.threads)
        expect(actualThreads.length).toBe(1)
        expect(actualThreads[0].subject).toEqual(someSubject)
        expect(actualThreads[0].emails).toEqual {email: email}

sumThreadEmails = (sum, thread) -> sum + _.size(thread.emails)
isEmailCategorized = (issues, numEmails) ->
  actualThreads = _.values(issues.threads)
  actualThreads.length >= 1 && _.reduce(actualThreads, sumThreadEmails, 0) == numEmails
