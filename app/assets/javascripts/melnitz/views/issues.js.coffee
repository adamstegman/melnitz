#= require melnitz/views/emails_view
#= require crucible
#= require jira
#= require q

# Public: The Melnitz section containing issue-related emails as defined in the README.
class @Melnitz.Issues extends @Melnitz.EmailsView
  header: "Issues and Code Reviews"
  initialize: ->
    @collection = new Melnitz.Emails
    @collection.url = "/emails/issues"
    # TODO: dependency injection
    @jira = new JIRA
    @crucible = new Crucible
    super
  updateThreads: ->
    _.each @collection.models, (email) =>
      this.getIssueDetails(email).done (issueDetails) =>
        parentIssueDetails = issueDetails?.fields?.parent
        subjectIssueKey = parentIssueDetails?.key ? issueDetails?.key
        subjectIssueSummary = parentIssueDetails?.fields?.summary ? issueDetails?.fields?.summary
        this.updateThread(email, formatIssueSubject(subjectIssueKey, subjectIssueSummary))
      , (error) =>
        this.updateThread(email, email.get("subject"))

  # Internal: Creates/updates a thread with the given subject, and ensures the given email is in it.
  updateThread: (email, subject) ->
    @threads[subject] ?= new Melnitz.Thread({subject: subject})
    @threads[subject].addEmail(email)
    this.render()

  # Internal: Returns a promise for the issue details related to the given email.
  #
  # If necessary, retrieves those details from the JIRA service.
  getIssueDetails: (email) ->
    issueDetails = this.getIssueDetailsFromCache(email)
    if issueDetails
      Q.fcall -> issueDetails
    else
      cacheIssueDetailsForEmail = _.partial(@cacheIssueDetails, email)
      this.getIssueKey(email)
        .then (issueKey) => this.fetchIssueDetails(issueKey)
        .then (issueDetails) ->
          cacheIssueDetailsForEmail(issueDetails)
          issueDetails

  # Internal: Returns a promise for the issue key for the given email.
  #
  # If necessary, retrieves the issue key from the Crucible API.
  getIssueKey: (email) ->
    if isCrucible(email)
      this.getReviewKey(email)
        .then (reviewKey) => this.fetchReviewDetails(reviewKey)
        .then (reviewDetails) => reviewDetails?.jiraIssueKey ? this.getKey(reviewDetails.name)
    else
      this.getKey(email.get("subject"))

  # Internal: Returns a promise for the review key for the given email.
  getReviewKey: (email) ->
    this.getKey(email.get("subject"))

  # Internal: Returns a promise for a JIRA/Crucible key from the given string.
  getKey: (string) ->
    key = extractKey(string)
    if key
      Q.fcall -> key
    else
      Q.fcall -> throw new Melnitz.Issues.MissingKeyError(email.get("id"))

  # Internal: Retrieves issue details for the issue with the given issueKey from the JIRA service.
  #
  # Returns a promise for the issue details.
  fetchIssueDetails: (issueKey) ->
    @jira.getIssue(issueKey)

  # Internal: Retrieves the review details for the Crucible review with the given reviewKey from the Crucible service.
  #
  # Returns a promise for the review details.
  fetchReviewDetails: (reviewKey) ->
    @crucible.getReview(reviewKey)

  # Internal: Attempts to retrieve the issue details for the given email from the cache.
  #
  # TODO: will want to invalidate this cache if I persist anything, or plan on this being long-lived
  #
  # Returns the issue details Object, or undefined if it is not cached.
  getIssueDetailsFromCache: (email) ->
    @jiraDetailsCache?[email.get("id")]

  # Internal: Caches the issueDetails for the given email to avoid another fetch.
  cacheIssueDetails: (email, issueDetails) ->
    @jiraDetailsCache ?= {}
    @jiraDetailsCache[email.get("id")] = issueDetails

# Public: No key could be extracted from the given Email.
class @Melnitz.Issues.MissingKeyError extends Error
  constructor: (@message) ->
    @name = "MissingKey"
    super

# Internal: Extracts a JIRA/Crucible key from the given string.
#
# Returns undefined if one could not be found.
extractKey = (string) -> /([A-Z]+-)+\d+/.exec(string)?[0]

# Internal: Formats the subject for a JIRA thread.
#
# issueKey     - The JIRA issue key
# issueSummary - The JIRA issue summary
formatIssueSubject = (issueKey, issueSummary) ->
  "#{issueKey}: #{issueSummary}"

# Internal: Returns true if the given email is considered a Crucible email.
isCrucible = (email) ->
  /^\[Crucible\]/.test(email?.get("subject"))
