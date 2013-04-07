#= require melnitz/views/emails_view

# Public: The Melnitz section containing issue-related emails as defined in the README.
class @Melnitz.Issues extends @Melnitz.EmailsView
  header: "Issues and Code Reviews"
  initialize: =>
    @collection = new Melnitz.Emails
    @collection.url = "/emails/issues"
    super
