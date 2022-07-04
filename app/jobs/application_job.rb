# frozen_string_literal: true

class ApplicationJob < ActiveJob::Base
  # Automatically retry jobs that encountered a deadlock
  # retry_on ActiveRecord::Deadlocked

  # Most jobs are safe to ignore if the underlying records are no longer available
  # discard_on ActiveJob::DeserializationError
  #
  #   3 Terminal to make it work
  # $ redis-server
  # $ bundle exec sidekiq
  # $ bin/rails s
end
