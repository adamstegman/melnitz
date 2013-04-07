# Public: An email dashboard. It renders several sections that organize email in a more approachable and actionable
# way.
@Melnitz = {}

# Internal: Handles clicks on navigation links by delegating to the router.
@Melnitz.navigate = (event) ->
  event.preventDefault()
  $('.melnitz-body').remove()
  Melnitz.router.navigate($(event.target).attr("href"), {trigger: true})
