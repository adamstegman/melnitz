# coding: UTF-8

require 'crucible'

# Public: Mirror of the Crucible review API so the JavaScript application can use it under the same domain.
class Crucible::ReviewsController < ApplicationController
  def show
    review_key = params[:id]
    review_details = Rails.application.crucible_client.fetch_review(review_key)
    if review_details
      render json: review_details
    else
      head 404
    end
  rescue Crucible::ServiceUnreachableError => e
    Rails.logger.info "Could not reach Crucible. #{e.message}"
    Rails.logger.info e.backtrace.join("\n")
    head 503
  end
end
