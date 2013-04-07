#= require melnitz

# Public: The main dashboard. It renders each section.
class @Melnitz.Dashboard extends Backbone.View
  tagName: "section"
  className: "melnitz-body"
  # TODO: pre-compile templates
  template: Handlebars.compile("""
    <section class="personal-body"></section>
    <section class="issues-body"></section>
    <section class="projects-body"></section>
    <section class="ucern-body"></section>
    """)

  initialize: (options) =>
    @model = new Melnitz.EmailSections
    if options.el
      @el = options.el
    else
      @$el.appendTo("body")
    if options.selectedEmailId
      @selectedEmailId = options.selectedEmailId

    this.listenTo(@model, "change", @updateSections)

  render: =>
    # Only need to #render these once, they will each listen for updates after that
    unless @sections
      # @$el.html() does not work
      $(@el).html(this.template())
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
