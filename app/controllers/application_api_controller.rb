class ApplicationApiController < ActionController::API
  class NotAuthorized < StandardError; end
  include ::ApplicationHelper

  before_action :authenticate_request
end
