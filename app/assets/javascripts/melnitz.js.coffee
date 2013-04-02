# Public: An email dashboard. It renders several sections that organize email in a more approachable and actionable
# way.
Melnitz = {}

# Internal: An email message that may or may not contain all of the following attributes. Any attribute may be null,
# undefined, or blank.
#
# id - the String base64 identifier of the email, used to retrieve email details
# bcc - an Array of email addresses bcc'd on this email.
# cc - an Array of email addresses cc'd on this email.
# ccDisplay - a String containing names of people cc'd on this email.
# from - the String email address this email was sent from.
# replyTo - an Array of email addresses to which replies to this email should be sent.
# sender - a String containing the name of the person this email was sent from.
# size - the Number of bytes in this email.
# subject - the String subject of this email.
# to - an Array of email addresses this email was sent to.
# toDisplay - a String containing the name of the person this email was sent to.
class Melnitz.Email extends Backbone.Model
  urlRoot: "/emails"
  url: =>
    @urlRoot + "/" + encodeURIComponent(this.get("id"))
  isHTML: =>
    this.get("bodyType") == "HTML"
  htmlBodyURL: =>
    this.url() + "/body"
  escapeId: (emailId) ->
    emailId.replace(/[^\w-]/g, "\\$&")
  unescapeId: (emailId) ->
    emailId.replace(/\\(.)/g, "$1")

# Internal: A single email display. Can be contained in any of the sections.
class Melnitz.EmailView extends Backbone.View
  tagName: "article"
  className: "email"
  template: Handlebars.compile("""
    <h3 class="subject">{{subject}}</h3>
    <dl class="attributes">
      {{#if from}}
      <dt>From</dt>
      <dd>{{from}}</dd>
      {{/if}}
      {{#if to}}
      <dt>To</dt>
      <dd>{{toDisplay}} {{to}}</dd>
      {{/if}}
      {{#if body}}
      <dt>Body</dt>
        {{#if isHTML}}
      <dd>
        <iframe src="{{{htmlBodyURL}}}" seamless sandbox></iframe>
      </dd>
        {{else}}
      <dd>{{body}}</dd>
        {{/if}}
      {{/if}}
    </dl>
    """)

  initialize: (args) ->
    @model = args ? args.model : null;
    if @model
      this.listenTo(@model, "change", @render);

  presenter: =>
    _.extend(_.clone(@model.attributes),
      htmlBodyURL: @model.htmlBodyURL()
      isHTML: @model.isHTML()
    )

  render: =>
    $(@el).html(this.template(this.presenter()));

# Internal: A collection of unread Email objects.
#
# Each View has a different URL to an emails collection, so the url is set in the View constructors.
class Melnitz.Emails extends Backbone.Collection
  model: Melnitz.Email
  parse: (resp) =>
    if resp then JSON.parse(resp).emails else undefined
  fetch: (options) =>
    superOptions = _.defaults(options ? {},
      beforeSend: @preFetch
      complete: @postFetch)
    Backbone.Collection.prototype.fetch.apply(this, [superOptions]);
  postFetch: (jqXHR, status) =>
    # TODO: add activity indicator
    jqXHR
  preFetch: (jqXHR, settings) =>
    # TODO: remove activity indicator
    jqXHR

# Internal: An abstract Melnitz section that contains a list of email threads.
class Melnitz.EmailsView extends Backbone.View
  tagName: "section"
  className: "melnitz-body"
  # TODO: pre-compile templates
  template: Handlebars.compile("""
    <h2>{{header}}</h2>
    <ol class="emails-list">
      {{#each emailIds}}
      <li class="email-list-item" data-email-id="{{this}}"></li>
      {{/each}}
    </ol>
    """)

  events:
    "click .email": "expandEmail"

  initialize: (options) ->
    if options.el
      @el = options.el
    else if $(".melnitz-body").length > 0
      @el = $(".melnitz-body").get(0)
    else
      @$el.appendTo("body")
    if options.selectedEmailId
      @selectedEmail = @collection.get(options.selectedEmailId)

    # TODO: is this efficient? it replaces everything when adding/removing an email
    this.listenTo(@collection, "add", @render)
    this.listenTo(@collection, "remove", @render)
    this.listenTo(@collection, "reset", @render)
    this.listenTo(@collection, "destroy", @render)

  expandEmail: (event) =>
    emailId = Melnitz.Email.unescapeId($(event.target).closest("[data-email-id]").data("email-id"))
    @collection.get(emailId).fetch()

  presenter: =>
    emailIds: @collection.pluck("id")
    header: @header

  render: =>
    # @$el.html() does not work
    $(@el).html(this.template(this.presenter()));
    _.each(@collection.models, (email) =>
      $(@el).find("[data-email-id='" + Melnitz.Email.escapeId(email.get("id")) + "']").each((index, el) ->
        emailView = new Melnitz.EmailView({model: email})
        $(el).append(emailView.el)
        emailView.render()))

# Public: The Melnitz section containing personal emails as defined in the README.
class Melnitz.Personal extends Melnitz.EmailsView
  header: "Personal Conversations"
  initialize: ->
    @collection = new Melnitz.Emails
    @collection.url = "/emails/personal"
    super(arguments)

# Public: The Melnitz section containing issue-related emails as defined in the README.
class Melnitz.Issues extends Melnitz.EmailsView
  header: "Issues and Code Reviews"
  initialize: ->
    @collection = new Melnitz.Emails
    @collection.url = "/emails/issues"
    super(arguments)

# Public: The Melnitz section containing project-related emails as defined in the README.
class Melnitz.Projects extends Melnitz.EmailsView
  header: "Project Updates"
  initialize: ->
    @collection = new Melnitz.Emails
    @collection.url = "/emails/projects"
    super(arguments)

# Public: The Melnitz section containing uCern-related emails as defined in the README.
class Melnitz.UCern extends Melnitz.EmailsView
  header: "uCern and Wiki Updates"
  initialize: ->
    @collection = new Melnitz.Emails
    @collection.url = "/emails/ucern"
    super(arguments)

# Internal: All unread emails, keyed by section.
class Melnitz.EmailSections extends Backbone.Model
  defaults:
    personal: []
    issues: []
    projects: []
    ucern: []

  url: =>
    "/emails"

# Public: The main dashboard. It renders each section.
class Melnitz.Dashboard extends Backbone.View
  tagName: "div"
  className: "melnitz-body"
  # TODO: pre-compile templates
  template: Handlebars.compile("""
    <section class="personal-body"></section>
    <section class="issues-body"></section>
    <section class="projects-body"></section>
    <section class="ucern-body"></section>
    """)

  initialize: (options) ->
    @model = new Melnitz.EmailSections
    if options.el
      @el = options.el
    else if $(".melnitz-body").length > 0
      @el = $(".melnitz-body").get(0)
    else
      @$el.appendTo("body")
    if options.selectedEmailId
      @selectedEmailId = options.selectedEmailId

    this.listenTo(@model, "change", @updateSections)

  render: =>
    # Only need to #render these once, they will each listen for updates after that
    unless this.sections
      # @$el.html() does not work
      $(@el).html(this.template());
      options = {selectedEmailId: @selectedEmailId}
      @sections = {}
      @sections.personal = new Melnitz.Personal(_.extend(options, {el: $(".personal-body").get(0)}))
      @sections.issues = new Melnitz.Issues(_.extend(options, {el: $(".issues-body").get(0)}))
      @sections.projects = new Melnitz.Projects(_.extend(options, {el: $(".projects-body").get(0)}))
      @sections.ucern = new Melnitz.UCern(_.extend(options, {el: $(".ucern-body").get(0)}))
      _.each(@sections, (section, key) =>
        section.collection.reset(@model.get(key)))

  updateSections: =>
    _.each(@sections, (section, key) =>
      section.collection.update(@model.get(key)))

class Melnitz.Router extends Backbone.Router
  # TODO: interpolate this from the server, create routes on server via metaprogramming, have one single list of sections
  routes:
    "personal(/:emailId)": "personal"
    "issues(/:emailId)": "issues"
    "projects(/:emailId)": "projects"
    "ucern(/:emailId)": "ucern"
    "(:emailId)": "dashboard"

  activateTopBarItem: (routeName) ->
    $(".top-bar-nav-link").removeClass("active")
    $(".top-bar-" + routeName).addClass("active")

  renderViewWithSelectedEmail: (viewClass, emailId, options) ->
    options ||= {}
    options.selectedEmailId = emailId
    view = new viewClass(options)
    view.render()
    view.collection.fetch({update: true})
  },

  dashboard: (emailId) =>
    this.activateTopBarItem("dashboard")
    options ||= {}
    options.selectedEmailId = emailId
    dashboard = new Melnitz.Dashboard(options)
    dashboard.render()
    dashboard.model.fetch()
  },

  personal: (emailId) =>
    # OPTIMIZE: when coming from dashboard, use the existing personal view instead of creating a new one
    this.activateTopBarItem("personal")
    this.renderViewWithSelectedEmail(Melnitz.Personal, emailId)

  issues: (emailId) =>
    this.activateTopBarItem("issues")
    this.renderViewWithSelectedEmail(Melnitz.Issues, emailId)

  projects: (emailId) =>
    this.activateTopBarItem("projects")
    this.renderViewWithSelectedEmail(Melnitz.Projects, emailId)

  ucern: (emailId) =>
    this.activateTopBarItem("ucern")
    this.renderViewWithSelectedEmail(Melnitz.UCern, emailId)

# Internal: Handles clicks on navigation links by delegating to the router.
Melnitz.navigate = (event) ->
  event.preventDefault()
  Melnitz.router.navigate($(event.target).attr("href"), {trigger: true})

Melnitz.router = new Melnitz.Router

Backbone.history.start({pushState: true})
$(document).on("click", "a.nav-link", Melnitz.navigate)
