#= require melnitz
#= require html_util

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
class @Melnitz.Email extends Backbone.Model
  urlRoot: "/emails"
  url: =>
    @urlRoot + "/" + encodeURIComponent(this.get("id"))
  expandedClassName: =>
    if this.get("expanded")
      "expanded email-expanded"
    else
      "collapsed email-collapsed"
  htmlSafeId: =>
    HTMLUtil.escapeAttr(this.get("id"))
  isHTML: =>
    this.get("body_type") == "HTML"
  htmlBodyURL: =>
    this.url() + "/body"
