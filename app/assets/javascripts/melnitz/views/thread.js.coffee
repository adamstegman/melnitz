#= require melnitz
#= require melnitz/models/email
#= require html_util

# Internal: A thread of emails, with an actionable summary as well as the details of each message in the thread.
class @Melnitz.Thread extends Backbone.View
  tagName: "section"
  className: "thread"
  # TODO: pre-compile templates
  template: Handlebars.compile """
    <h3 class="subject thread-subject thread-toggle">{{subject}}</h2>
    {{#if expanded}}
    <ol class="emails-list">
      {{#each emails}}
      <li class="email-list-item {{expandedClassName}}" data-email-id="{{id}}"></li>
      {{/each}}
    </ol>
    {{/if}}
    """

  events:
    "click .email-toggle": "toggleEmail"

  initialize: (options) ->
    emails = options?.emails ? []
    @emails = {}
    _.each emails, (email) =>
      this.addEmail(email)
    @subject = Melnitz.Thread.extractSubject(emails[0])
    @htmlSafeSubject = HTMLUtil.escapeAttr(@subject)
    # TODO: @summary

  toggleEmail: (event) =>
    emailId = HTMLUtil.unescapeAttr($(event.target).closest("[data-email-id]").data("email-id"))
    email = @emails[emailId]
    expanded = !(email.get("expanded"))
    email.set("expanded", expanded)
    if expanded
      email.fetch()

  presenter: =>
    emails: _.values(@emails)
    expanded: @expanded
    subject: @subject

  render: =>
    @$el.html(this.template(this.presenter()))
    _.each @emails, (email) =>
      @$el.find("[data-email-id='" + email.htmlSafeId() + "']").each (index, el) =>
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

  expandedClassName: =>
    if @expanded
      "expanded thread-expanded"
    else
      "collapsed thread-collapsed"

@Melnitz.Thread.extractSubject = (email) ->
  # TODO: more advanced, e.g. ignoring parentheticals?
  email?.get("subject")?.replace(/(^canceled|fw|re):{1,}\s*/gi, "").trim()
