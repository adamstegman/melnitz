# coding: UTF-8

# Public: Holds emails, grouped by section.
#
# See the README for more information about how the emails are grouped.
class Dashboard
  # Public: Gets emails that do not correspond to other sections.
  attr_reader :personal

  # Public: Gets emails about JIRA issues.
  attr_reader :issues

  # Public: Gets emails about projects.
  attr_reader :projects

  # Public: Gets emails from uCern.
  attr_reader :ucern

  # Internal: Matches JIRA and Crucible identifiers, e.g. `(PHAPPINFRA-CR-239)`.
  JIRA_SUBJECT = /\([\w-]+-\d+\)/

  # Internal: Matches project identifiers, e.g. `[provider_portal]`.
  #
  # TODO: needs to be better, will also match [Crucible]
  PROJECT_SUBJECT = /^.+\[[\w-]+\]/

  # Internal: Matches uCern subject lines, e.g. `[Population Health App Infra] - ` or `[uCern Wiki] `.
  UCERN_SUBJECT = /^(\[[^\]]+\] - |\[uCern Wiki\] )/

  # Public: Constructs a dashboard, grouping the given emails by section.
  #
  # emails - An Array of Email objects to group by section.
  def initialize(emails = [])
    @personal = []
    @issues = []
    @projects = []
    @ucern = []
    emails.each do |email|
      personal = true
      if issue_email?(email)
        @issues << email
        personal = false
      end
      if project_email?(email)
        @projects << email
        personal = false
      end
      if ucern_email?(email)
        @ucern << email
        personal = false
      end
      if personal
        @personal << email
      end
    end
  end

  # Internal: Returns whether email pertains to a JIRA issue or a Crucible review.
  def issue_email?(email)
    email.subject =~ JIRA_SUBJECT
  end

  # Internal: Returns whether email pertains to a project.
  def project_email?(email)
    email.subject =~ PROJECT_SUBJECT
  end

  # Internal: Returns whether email is from uCern or uCern Wiki.
  def ucern_email?(email)
    email.subject =~ UCERN_SUBJECT
  end
end
