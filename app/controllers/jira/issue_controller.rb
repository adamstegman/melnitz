# coding: UTF-8

require 'jira'

# Public: Mirror of the JIRA issue API so the JavaScript application can use it under the same domain.
class Jira::IssueController < ApplicationController
  def show
    issue_key = params[:id]
    issue_details = Rails.application.jira_client.fetch_issue(issue_key)
    if issue_details
      render json: issue_details
    else
      head 404
    end
  rescue JIRA::ServiceUnreachableError => e
    Rails.logger.info "Could not reach JIRA. #{e.message}"
    Rails.logger.info e.backtrace.join("\n")
    head 503
  end
end
