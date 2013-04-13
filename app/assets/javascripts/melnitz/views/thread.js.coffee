#= require melnitz
#= require melnitz/models/email

# Internal: A thread of emails, with an actionable summary as well as the details of each message in the thread.
class @Melnitz.Thread extends Backbone.View
  tagName: "section"
  className: "thread"
  # TODO: pre-compile templates
  template: Handlebars.compile """
    <h3>{{subject}}</h2>
    <ol class="emails-list">
      {{#each emailIds}}
      <li class="email-list-item" data-email-id="{{this}}"></li>
      {{/each}}
    </ol>
    """

  events:
    "click .email": "toggleEmail"

  initialize: (options) ->
    emails = options?.emails ? []
    @emails = {}
    _.each emails, (email) =>
      this.addEmail(email)
    @subject = Melnitz.Thread.extractSubject(emails[0])

  toggleEmail: (event) =>
    emailId = Melnitz.Email.unescapeId($(event.target).closest("[data-email-id]").data("email-id"))
    email = @emails[emailId]
    expanded = !(email.get("expanded"))
    email.set("expanded", expanded)
    if expanded
      email.fetch()

  presenter: =>
    emailIds: _.keys(@emails),
    subject: @subject

  render: =>
    @$el.html(this.template(this.presenter()))
    _.each _.keys(@emails), (emailId) =>
      email = @emails[emailId]
      @$el.find("[data-email-id='" + Melnitz.Email.escapeId(emailId) + "']").each (index, el) =>
        emailView = new Melnitz.EmailView({model: email})
        $(el).append(emailView.el)
        emailView.render()
      this.delegateEvents()

  addEmail: (email) =>
    existingEmail = this.includesEmail(email)
    @emails[email.get("id")] = email
    unless existingEmail
      this.trigger("thread:addEmail", this, email)
    # TODO: update event

  includesEmail: (email) =>
    @emails.hasOwnProperty(email.get("id"))

@Melnitz.Thread.extractSubject = (email) ->
  # TODO: more advanced, e.g. ignoring parentheticals?
  #       "Canceled: " prefix
  email?.get("subject")?.replace(/(fw|re):{1,}\s*/gi, "").trim()
