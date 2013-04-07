#= require melnitz/views/emails_view

# Public: The Melnitz section containing uCern-related emails as defined in the README.
class @Melnitz.UCern extends @Melnitz.EmailsView
  header: "uCern and Wiki Updates"
  initialize: =>
    @collection = new Melnitz.Emails
    @collection.url = "/emails/ucern"
    super
