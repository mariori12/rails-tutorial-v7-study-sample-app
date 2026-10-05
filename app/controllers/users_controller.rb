# frozen_string_literal: true

# UsersController handles user profiles and signup.
class UsersController < ApplicationController
  def show
    @user = User.find(params[:id])
  end

  def new; end
end
