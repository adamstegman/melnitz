#= require melnitz/views/emails_view

# Public: The Melnitz section containing project-related emails as defined in the README.
class @Melnitz.Projects extends @Melnitz.EmailsView
  header: "Project Updates"
  initialize: =>
    @collection = new Melnitz.Emails
    @collection.url = "/emails/projects"
    super
