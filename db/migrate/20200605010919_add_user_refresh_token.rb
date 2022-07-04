# frozen_string_literal: true

class AddUserRefreshToken < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :refresh_token, :string
  end
end
