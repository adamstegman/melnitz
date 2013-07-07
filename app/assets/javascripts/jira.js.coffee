#= require q

# Public: Client for Melnitz' JIRA API mirror.
class @JIRA
  constructor: ->
    @base_uri = "/jira"

  # Public: Retrieves details about the issue identified by the given key.
  #
  # issueKey - A String issue key, which can be either the full issue key (e.g. "MYISSUE-1") or the issue id (e.g. 57938).
  #
  # Returns a Promise for the resulting issue data (as an Object).
  getIssue: (issueKey) =>
    uri = "#{@base_uri}/issue/#{issueKey}"
    request = new XMLHttpRequest
    response = Q.defer()
    request.open("GET", uri)
    request.setRequestHeader("Accept", "application/json")
    request.onreadystatechange = ->
      if request.readyState == 4
        if request.status == 200
          try
            response.resolve(JSON.parse(request.responseText))
          catch e
            response.reject(e)
        else
          response.reject(new JIRA.NotFoundError(request.statusText))
    request.onerror = -> response.reject(new JIRA.ServiceUnreachableError)
    request.send()
    response.promise

# Public: The issue was not found.
class @JIRA.NotFoundError extends Error
  constructor: (@message) ->
    @name = "NotFound"
    super

# Public: The JIRA service was unreachable due to timeout, DNS error, etc.
class @JIRA.ServiceUnreachableError extends Error
  constructor: (@message) ->
    @name = "ServiceUnreachable"
    super
