# frozen_string_literal: true

class ApplicationTurboController < ActionController::Base
  include ApplicationHelper

  layout 'application_turbo'

  before_action :auth_user!

  def auth_user!
    redirect_to '/login' unless session[:current_user_id]
  end
end
