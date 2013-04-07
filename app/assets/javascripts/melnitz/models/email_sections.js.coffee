#= require melnitz

# Internal: All unread emails, keyed by section.
class @Melnitz.EmailSections extends Backbone.Model
  defaults:
    personal: []
    issues: []
    projects: []
    ucern: []

  parse: (resp) =>
    resp?._embedded

  url: =>
    "/emails"
