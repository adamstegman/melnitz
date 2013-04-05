# coding: UTF-8

# Public: Renders Exchange email details as JSON, grouped according to which action was called.
#
# See the README for more information about how the emails are grouped.
class EmailsController < ApplicationController
  include Roar::Rails::ControllerAdditions
  respond_to :json

  # Public: Renders a summary of all unread emails, grouped by sections of the application.
  #
  # Groups correspond to the actions in this controller. Calling one of those actions would return the same set of
  # emails as in the group this action returns.
  def index
    dashboard = fetch_email_dashboard
    respond_with dashboard, represent_with: DashboardRepresenter
  end

  # Public: Renders a summary of all unread emails that do not correspond to other sections.
  def personal
    dashboard = fetch_email_dashboard
    respond_with Emails.new(dashboard.personal, personal_emails_url)
  end

  # Public: Renders a summary of all unread emails about JIRA issues.
  def issues
    dashboard = fetch_email_dashboard
    respond_with Emails.new(dashboard.issues, issues_emails_url)
  end

  # Public: Renders a summary of all unread emails about projects.
  def projects
    dashboard = fetch_email_dashboard
    respond_with Emails.new(dashboard.projects, projects_emails_url)
  end

  # Public: Renders a summary of all unread emails from uCern.
  def ucern
    dashboard = fetch_email_dashboard
    respond_with Emails.new(dashboard.ucern, ucern_emails_url)
  end

  # Public: Renders the details of the requested email. The ID is the Exchange ID of the email.
  def show
    email_message = Rails.application.exchange_client.fetch_email_details(params[:id])
    email = Email.new(email_message)
    respond_with email
  end

  private

  def fetch_email_dashboard
    email_messages = Rails.application.exchange_client.fetch_all_unread_emails
    emails = email_messages.map(&Email.method(:new))
    Dashboard.new(emails)
  end
end

# Internal: Holds a collection of Email objects and the URL at which they were retrieved.
Emails = Struct.new(:emails, :url)
