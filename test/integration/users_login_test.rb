# frozen_string_literal: true

require 'test_helper'

class UsersLogin < ActionDispatch::IntegrationTest
  def setup
    @user = users(:michael)
  end

end

class InvalidLoginTest < UsersLogin
  test 'login with valid email and invalid password' do
    post login_path, params: { session: { email: @user.email, password: 'invalid' } }
    assert_not is_logged_in?
    assert_response :unprocessable_entity
    assert_select 'title', full_title('Log in')
    assert_not flash.empty?
    get root_path
    assert flash.empty?
  end

  test 'login with invalid information' do
    get login_path
    assert_response :success
    post login_path, params: { session: { email: '', password: '' } }
    assert_response :unprocessable_entity
    assert_not is_logged_in?
    assert_select 'title', full_title('Log in')
    assert_not flash.empty?
    assert_select '.alert.alert-danger', text: 'Invalid email/password combination'
    get root_path
    assert flash.empty?
    assert_select '.alert.alert-danger', count: 0
  end
end

class ValidLogin < UsersLogin
  def setup
    super
    get login_path
    @previous_session_id = session.id.to_s
    post login_path, params: { session: { email: @user.email.upcase, password: 'password' } }
  end
end

class ValidLoginTest < ValidLogin
  test 'login stores the user in a renewed session' do
    assert is_logged_in?
    assert_equal @user.id, session[:user_id]
    assert_not_equal @previous_session_id, session.id.to_s
    assert_response :see_other
    assert_redirected_to @user
    cookie = response.headers['Set-Cookie'].to_s
    assert_includes cookie.downcase, 'httponly'
    assert_no_match(/expires=/i, cookie)
  end

  test 'redirected profile has logged in links' do
    follow_redirect!
    assert_response :success
    assert_select 'title', full_title(@user.name)
    assert_select 'a[href=?]', login_path, count: 0
    assert_select 'a[href=?][data-turbo-method=delete]', logout_path
    assert_select 'a[href=?]', user_path(@user)
  end

  test 'deleting the session cookie ends the login' do
    cookies.delete(Rails.application.config.session_options[:key])
    get root_path
    assert_not is_logged_in?
    assert_select 'a[href=?]', login_path
    assert_select '#account', count: 0
  end
end

class Logout < ValidLogin
  def setup
    super
    @logged_in_session_id = session.id.to_s
    delete logout_path
  end
end

class LogoutTest < Logout
  test 'logout clears and renews the session' do
    assert_not is_logged_in?
    assert_not_equal @logged_in_session_id, session.id.to_s
    assert_response :see_other
    assert_redirected_to root_url
  end

  test 'redirected home has logged out links' do
    follow_redirect!
    assert_response :success
    assert_select 'a[href=?]', login_path
    assert_select 'a[href=?]', logout_path, count: 0
    assert_select 'a[href=?]', user_path(@user), count: 0
    assert_select '#account', count: 0
  end

  test 'logging out again is harmless' do
    delete logout_path
    assert_not is_logged_in?
    assert_response :see_other
    assert_redirected_to root_url
  end
end
