#= require melnitz/models/email

# Internal: A collection of unread Email objects.
#
# Each View has a different URL to an emails collection, so the url is set in the View constructors.
class @Melnitz.Emails extends Backbone.Collection
  model: Melnitz.Email
  parse: (resp) =>
    resp?._embedded?.emails
  fetch: (options) =>
    superOptions = _.defaults(options ? {},
      beforeSend: @preFetch
      complete: @postFetch)
    super(superOptions)
  postFetch: (jqXHR, status) =>
    # TODO: add activity indicator
    jqXHR
  preFetch: (jqXHR, settings) =>
    # TODO: remove activity indicator
    jqXHR
