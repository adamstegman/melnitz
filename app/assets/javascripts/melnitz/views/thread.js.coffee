#= require melnitz
#= require melnitz/models/email
#= require html_util

# Public: A thread of emails, with an actionable summary as well as the details of each message in the thread.
class @Melnitz.Thread extends Backbone.View
  tagName: "section"
  className: "thread"
  # TODO: pre-compile templates
  template: Handlebars.compile """
    <h3 class="subject thread-subject thread-toggle">{{subject}}</h3>
    <ol class="emails-list">
      {{#each emails}}
      <li class="email-list-item {{expandedClassName}}" data-email-id="{{id}}"></li>
      {{/each}}
    </ol>
    """

  events: ->
    "click .email-toggle": "toggleEmail"

  # Public: Creates a thread with the given options.
  #
  # options - An object:
  #           emails  - A list of emails to initialize the thread with. Each will be added individually, triggering an
  #                    event.
  #           subject - A predefined subject for the thread (default: extractSubject(emails[0])).
  initialize: (options) ->
    emails = options?.emails ? []
    @subject = options?.subject
    @emails = {}
    _.each emails, (email) => @addEmail(email)

  # Public: Toggles the display of the email indicated by the event. The email is discovered by reading the closest
  # data-email-id attribute.
  toggleEmail: (event) =>
    $emailContainer = $(event.target).closest("[data-email-id]")
    emailId = HTMLUtil.unescapeAttr($emailContainer.data("email-id"))
    email = @emails[emailId]
    $emailContainer.removeClass(email.expandedClassName())
    expanded = !(email.get("expanded"))
    email.set("expanded", expanded)
    $emailContainer.addClass(email.expandedClassName())
    email.fetch() if expanded

  # Internal: Exposes attributes to the template.
  presenter: =>
    emails: _.values(@emails)
    subject: @subject

  # Public: Renders the HTML of this view, replacing any existing HTML.
  render: =>
    @$el.html(@template(@presenter()))
    if @expanded
      _.each @emails, (email) =>
        @$el.find("[data-email-id='" + email.htmlSafeId() + "']").each (index, el) =>
          emailView = new Melnitz.EmailView({model: email})
          $(el).append(emailView.el)
          emailView.render()
    @delegateEvents()

  # Public: Adds the given email to this thread.
  #
  # Triggers a "thread:addEmail" event if the email was not already part of this thread.
  addEmail: (email) =>
    existingEmail = @includesEmail(email)
    @emails[email.get("id")] = email
    @subject = Melnitz.Thread.extractSubject(email) unless @subject
    @trigger("thread:addEmail", this, email) unless existingEmail
    # TODO: update event

  # Public: Returns the thread identifier. By default, this is the subject, but subclasses may override.
  id: =>
    @htmlSafeSubject ?= HTMLUtil.escapeAttr(@subject) if @subject

  # Public: Returns whether or not the given email is in this thread.
  includesEmail: (email) =>
    @emails.hasOwnProperty(email.get("id"))

  # Internal: Returns the appropriate HTML class names for whether the thread is expanded or collapsed.
  expandedClassName: =>
    if @expanded
      "expanded thread-expanded"
    else
      "collapsed thread-collapsed"

# Public: Extracts a common subject from the given email. Eliminates unnecessary pieces like FW: and RE:, and trailing
# parentheticals.
@Melnitz.Thread.extractSubject = (email) ->
  # TODO: more advanced, e.g. ignoring parentheticals?
  emailSubject = email?.get("subject")
  return emailSubject unless emailSubject
  removals = [
    # indicators that do not change the subject core, e.g. "FW:"
    /(^canceled|fw|re):{1,}\s*/gi,
    # trailing parentheticals
    /\([^\)]+\)\s*$/g
  ]
  remove = (subject, removal) ->
    subject.replace(removal, "")
  _.reduce(removals, remove, emailSubject).trim()
