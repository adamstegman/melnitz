#= require melnitz

class @Melnitz.Router extends Backbone.Router
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

  renderViewWithSelectedEmail: (viewClass, emailId) ->
    view = new viewClass({selectedEmailId: emailId})
    view.render()
    view.collection.fetch({update: true})

  dashboard: (emailId) =>
    this.activateTopBarItem("dashboard")
    dashboard = new Melnitz.Dashboard({selectedEmailId: emailId})
    dashboard.render()
    dashboard.model.fetch()

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
