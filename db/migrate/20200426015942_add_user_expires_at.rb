# frozen_string_literal: true

class AddUserExpiresAt < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :expires_at, :integer
  end
end
