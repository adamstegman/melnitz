# coding: UTF-8

# Public: Wraps an Exchange EmailMessage to provide an application-specific API.
Email = Struct.new(:email_message) do
  # Public: Returns the String identifier for the email.
  def id
    email_message.id.to_s
  end

  # Public: Returns the URL-escaped #id.
  def url_escaped_id
    CGI.escape(id)
  end

  # Public: Returns an Array of String email addresses blind carbon-copied on this email.
  def bcc
    email_message.bcc_recipients.map(&:to_s)
  end

  # Public: Returns the String body of this email.
  #
  # The body is determined by Exchange and will contain only one part of the message, typically the HTML part if that
  # exists. The body type is indicated by #body_type.
  #
  # If the email is a thread, this String will contain the entire thread as it would appear in the email.
  def body
    # TODO: unique_body?
    email_message.body.to_s
  end

  # Public: Returns a String representing the body type of this email.
  #
  # Value will be one of the BodyType enumeration values.
  def body_type
    email_message.body.body_type.to_s
  end

  # Public: Returns an Array of String email addresses carbon-copied on this email.
  def cc
    email_message.cc_recipients.map(&:to_s)
  end

  # Public: Returns a String containing the formatted display names of the carbon-copy recipients.
  #
  # TODO: Examples
  def cc_display
    email_message.display_cc
  end

  # Public: Returns the String email address that this email is from.
  def from
    email_message.from.to_s
  end

  # Public: Returns an Array of String email address to which replies to this email should be addressed.
  def reply_to
    email_message.reply_to.map(&:to_s)
  end

  # Public: Returns the String email address that sent this email.
  def sender
    email_message.sender.to_s
  end

  # Public: Returns the Integer size of this email in bytes. TODO: I assume it's bytes
  def size
    email_message.size
  end

  # Public: Returns the String subject of this email.
  def subject
    email_message.subject
  end

  # Public: Returns an Array of String email addresses this email was addressed to.
  def to
    email_message.to_recipients.map(&:to_s)
  end

  # Public: Returns a String containing the formatted display names of the recipients of this email.
  def to_display
    email_message.display_to
  end
end
