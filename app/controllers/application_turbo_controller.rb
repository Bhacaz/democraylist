# frozen_string_literal: true

class ApplicationTurboController < ActionController::Base
  include ApplicationHelper

  layout 'application_turbo'

  before_action :auth_user!
  before_action :turbo_frame_request_variant

  private

  def turbo_frame_request_variant
    request.variant = :turbo_frame if turbo_frame_request?
  end

  def auth_user!
    redirect_to '/login' unless authenticated?
  end
end
