#= require melnitz/views/emails_view

# Public: The Melnitz section containing personal emails as defined in the README.
class @Melnitz.Personal extends @Melnitz.EmailsView
  header: "Personal Conversations"
  initialize: =>
    @collection = new Melnitz.Emails
    @collection.url = "/emails/personal"
    super
