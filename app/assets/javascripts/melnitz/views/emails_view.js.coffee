#= require melnitz

# Internal: An abstract Melnitz section that contains a list of email threads.
class @Melnitz.EmailsView extends Backbone.View
  tagName: "section"
  className: "melnitz-body"
  # TODO: pre-compile templates
  template: Handlebars.compile """
    <h2>{{header}}</h2>
    <ol class="threads-list">
      {{#each threads}}
      <li class="thread-list-item {{expandedClassName}}" data-thread-id="{{{id}}}"></li>
      {{/each}}
    </ol>
    """

  events:
    "click .thread-toggle": "toggleThread"

  initialize: (options) =>
    if options?.el
      @el = options.el
    else
      @$el.appendTo("body")
    # TODO: maintain expanded threads and expanded emails in query/hash parameters
    @threads = {}

    # FIXME: run these in a background worker so they don't block the UI
    this.listenTo(@collection, "add", @updateThreads)
    this.listenTo(@collection, "remove", @updateThreads)
    this.listenTo(@collection, "reset", @updateThreads)
    this.listenTo(@collection, "destroy", @updateThreads)

  toggleThread: (event) =>
    $threadContainer = $(event.target).closest("[data-thread-id]")
    threadId = HTMLUtil.unescapeAttr($threadContainer.data("thread-id"))
    thread = @threads[threadId]
    $threadContainer.removeClass(thread.expandedClassName())
    thread.expanded = !(thread.expanded)
    $threadContainer.addClass(thread.expandedClassName())
    thread.render()

  updateThreads: =>
    # FIXME: need a way to only see the added/removed emails, want to simply add/remove emails from threads without doing all this iteration
    # FIXME: this does not remove, only adds/updates
    # OPTIMIZE: I feel like a Threads collection should handle this logic and this just renders it
    _.each @collection.models, (email) =>
      thread = new Melnitz.Thread({emails: [email]})
      if @threads[thread.id()]
        @threads[thread.id()].addEmail(email)
      else
        @threads[thread.id()] = thread
    # TODO: is this efficient? it replaces everything when adding/removing emails
    #       may want to have a separate function that updates the rendering rather than replacing it
    this.render()

  threadList: =>
    _.values(@threads)

  presenter: =>
    header: @header
    threads: this.threadList()

  render: =>
    # @$el.html() does not work
    $(@el).html(this.template(this.presenter()))
    threadListItems = $(@el).find('.thread-list-item')
    _.each _.values(@threads), (thread, i) =>
      $(threadListItems[i]).append(thread.el)
      thread.render()
