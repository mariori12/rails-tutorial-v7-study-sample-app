# frozen_string_literal: true

# SessionsController handles login and logout.
class SessionsController < ApplicationController
  def new; end

  def create
    credentials = params.require(:session).permit(:email, :password)
    user = User.find_by(email: credentials[:email].to_s.downcase)
    if user&.authenticate(credentials[:password].to_s)
      reset_session
      log_in user
      redirect_to user, status: :see_other
    else
      flash.now[:danger] = 'Invalid email/password combination'
      render 'new', status: :unprocessable_entity
    end
  end

  def destroy
    log_out
    redirect_to root_url, status: :see_other
  end
end
