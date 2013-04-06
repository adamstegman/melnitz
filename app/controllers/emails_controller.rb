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
    respond_with fetch_email(params[:id])
  end

  # Public: Renders the HTML body of the requested email. The ID is the Exchange ID of the email.
  def body
    render text: fetch_email(params[:id]).body, content_type: 'text/html'
  end

  private

  def fetch_email_dashboard
    email_messages = exchange_client.fetch_all_unread_emails
    emails = email_messages.map(&Email.method(:new))
    Dashboard.new(emails)
  end

  def fetch_email(id)
    email_message = exchange_client.fetch_email_details(id)
    Email.new(email_message)
  end

  def exchange_client
    Rails.application.exchange_client
  end
end

# Internal: Holds a collection of Email objects and the URL at which they were retrieved.
Emails = Struct.new(:emails, :url)
