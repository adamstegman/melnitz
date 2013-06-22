#= require q

# Public: Client for Melnitz' Crucible API mirror.
class @Crucible
  constructor: ->
    @base_uri = "/crucible"

  # Public: Retrieves details about the review identified by the given key.
  #
  # reviewKey - A String review key, e.g. "MYISSUE-CR-1".
  #
  # Returns a Promise for the resulting review data (as an Object).
  getReview: (reviewKey) =>
    uri = "#{@base_uri}/reviews/#{reviewKey}"
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
          response.reject(new Crucible.NotFoundError(request.statusText))
    request.onerror = -> response.reject(new Crucible.ServiceUnreachableError)
    request.send()
    response.promise

# Public: The review was not found.
class @Crucible.NotFoundError extends Error
  constructor: (@message) ->
    @name = "NotFound"
    super

# Public: The Crucible service was unreachable due to timeout, DNS error, etc.
class @Crucible.ServiceUnreachableError extends Error
  constructor: (@message) ->
    @name = "ServiceUnreachable"
    super
