#= require melnitz

# Internal: An abstract Melnitz section that contains a list of email threads.
class @Melnitz.EmailsView extends Backbone.View
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

  initialize: (options) =>
    if options.el
      @el = options.el
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
    $(@el).html(this.template(this.presenter()))
    _.each(@collection.models, (email) =>
      $(@el).find("[data-email-id='" + Melnitz.Email.escapeId(email.get("id")) + "']").each((index, el) ->
        emailView = new Melnitz.EmailView({model: email})
        $(el).append(emailView.el)
        emailView.render()))
