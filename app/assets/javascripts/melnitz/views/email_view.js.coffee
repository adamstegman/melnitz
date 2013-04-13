#= require melnitz

# Internal: A single email display. Can be contained in any of the sections.
#
# TODO: linkify text body
class @Melnitz.EmailView extends Backbone.View
  tagName: "article"
  className: "email"
  template: Handlebars.compile("""
    <h4 class="subject">{{subject}}</h3>
    {{#if expanded}}
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
        <iframe class="email-body email-body-html" seamless sandbox src="{{{htmlBodyURL}}}"></iframe>
      </dd>
        {{else}}
      <dd><pre class="email-body email-body-text">{{body}}</pre></dd>
        {{/if}}
      {{/if}}
    </dl>
    {{/if}}
    """)

  initialize: (args) =>
    @model = args?.model
    if @model
      this.listenTo(@model, "change", @render)

  presenter: =>
    _.extend(_.clone(@model.attributes),
      htmlBodyURL: @model.htmlBodyURL()
      isHTML: @model.isHTML()
    )

  render: =>
    $(@el).html(this.template(this.presenter()))
